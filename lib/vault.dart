import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class PermissionError extends Error {
  final String message;

  PermissionError(this.message);

  @override
  String toString() => message;
}

class VaultsManager {
  static List<Vault> storedVaults = [];
  static late final String appFolder;
  static late final File mainConfigFile;
  static final cipher = Chacha20(macAlgorithm: MacAlgorithm.empty);
  static bool shouldUpdateVaultList = false;

  static void saveVaults() {
    mainConfigFile.writeAsStringSync(jsonEncode({
      "chests": [for (Vault vault in storedVaults) vault.toJson()]
    }));

    for (Vault vault in storedVaults) {
      File recognizerFile = File(vault.filesMetadataBankPath);
      recognizerFile.createSync(recursive: true);
      recognizerFile.writeAsStringSync(vault.toRawJson());
    }
  }

  static void loadVaults() {
    late Map<String, dynamic> chests;

    try {
      chests = jsonDecode(mainConfigFile.readAsStringSync());
    } on FormatException {
      chests = {'chests': []};
    }

    List<Vault> constructedVaults = [];
    for (Map<String, dynamic> chest in chests['chests']) {
      constructedVaults.add(Vault.fromJson(chest));
    }
    storedVaults = constructedVaults;
  }

  static Future<Vault> createVaultFromPolicy(VaultPolicy policy) async {
    String path = p.join(VaultsManager.appFolder, '.${md5RandomFileName()}');
    // Do not edit the witness test file, please I beg you
    File keyFile = File(p.join(path, '.witness'));
    keyFile.createSync(recursive: true);
    SecretKey cryptKey = SecretKey(passwordToCryptKey(policy.vaultPassword));
    // NOTE: An IV is not needed here as the first block of an encryption won't really matter because the data structure generated by this app is known.
    SecretBox encryptedWitnessFile = await cipher.encrypt(
        utf8.encode(await rootBundle
            .loadString('file_settings/encryption_witness_file', cache: false)),
        secretKey: cryptKey,
        nonce: Uint8List(cipher.nonceLength));

    File witnessFile = File(p.join(path, '.witness'));
    witnessFile.createSync(recursive: true);
    debugPrint(encryptedWitnessFile.nonce.toString());
    debugPrint(encryptedWitnessFile.mac.toString());
    debugPrint(encryptedWitnessFile.cipherText.toString());
    witnessFile.writeAsBytesSync(encryptedWitnessFile.cipherText);

    Vault createdVault = Vault(
        locked: false,
        creationDate: DateTime.now(),
        filesMetadataBankPath: p.join(path, '.${md5RandomFileName()}'),
        path: path,
        name: policy.vaultName,
        shouldDisconnectWhenVaultOpened: policy.shouldDisconnectWhenVaultOpened,
        securityLevel: policy.securityLevel,
        encryptionKey: cryptKey);

    File mapFile = File(p.join(path, '.map'));
    mapFile.createSync(recursive: true);

    mapFile.writeAsBytesSync(
        (await encryptMap(createdVault, constructMap(createdVault)))!);

    return createdVault;
  }

  static void deleteVault(Vault vault) {
    saveVaults();
    storedVaults.remove(vault);
    Directory folderToDelete = Directory(vault.path);

    folderToDelete.deleteSync(recursive: true);
    saveVaults();
  }

  static Future<bool> testVaultKey(Vault vault) async {
    File witnessFile = File(p.join(vault.path, '.witness'));

    if (vault.encryptionKey == null || !witnessFile.existsSync()) return false;
    String decryptedWitnessFile = utf8.decode(
        await cipher.decrypt(
            SecretBox(witnessFile.readAsBytesSync(),
                nonce: Uint8List(cipher.nonceLength), mac: Mac.empty),
            secretKey: vault.encryptionKey!),
        allowMalformed: true);

    return decryptedWitnessFile ==
        await rootBundle.loadString('file_settings/encryption_witness_file',
            cache: false);
  }

  static Map<String, dynamic> constructMap(Vault vault,
      {Map<String, dynamic>? oldMap, Map<String, String>? additionalFiles}) {
    Map<String, dynamic> newMap = {};
    oldMap ??= {};
    additionalFiles ??= {};
    for (FileSystemEntity file in Directory(vault.path).listSync()) {
      String localPath = file.path.substring(vault.path.length + 1);

      if (localPath.startsWith('.')) continue;

      newMap[localPath] = 'unknown';
    }

    for (MapEntry<String, dynamic> oldFile in oldMap.entries.toList()
      ..addAll(additionalFiles.entries)) {
      if (newMap[oldFile.key] != null) {
        newMap[oldFile.key] = oldFile.value;
      }
    }
    return newMap;
  }

  static Future<List<int>?> encryptMap(
      Vault vault, Map<String, dynamic> initialMap) async {
    if (vault.encryptionKey == null) return null;

    return (await cipher.encrypt(utf8.encode(jsonEncode(initialMap)),
            secretKey: vault.encryptionKey!,
            nonce: Uint8List(cipher.nonceLength)))
        .cipherText;
  }

  static Future<Map<String, dynamic>?> decryptMap(
      Vault vault, List<int> encryptedMap) async {
    if (vault.encryptionKey == null) return null;
    debugPrint(encryptedMap.toString());
    Map<String, dynamic> decryptedMap = jsonDecode(utf8.decode(
        await cipher.decrypt(
            SecretBox(encryptedMap,
                nonce: Uint8List(cipher.nonceLength), mac: Mac.empty),
            secretKey: vault.encryptionKey!)));

    return decryptedMap;
  }
}

class VaultPolicy {
  bool isInternalVault;
  String vaultName;
  String vaultPassword;
  bool shouldDisconnectWhenVaultOpened;
  int securityLevel;

  VaultPolicy({
    this.isInternalVault = true,
    this.vaultName = 'Unnamed vault',
    this.vaultPassword = '',
    this.shouldDisconnectWhenVaultOpened = false,
    this.securityLevel = 2,
  });
}

String md5RandomFileName() {
  final randomNumber = Random.secure().nextDouble();
  final randomBytes = utf8.encode(randomNumber.toString());
  final randomString = crypto.md5.convert(randomBytes).toString();
  return randomString;
}

List<int> passwordToCryptKey(String password) {
  return crypto.md5.convert(utf8.encode(password)).toString().codeUnits;
}

/// Represents a vault data-wise
class Vault {
  Vault(
      {required this.locked,
      required this.path,
      required this.creationDate,
      required this.filesMetadataBankPath,
      required this.name,
      required this.shouldDisconnectWhenVaultOpened,
      required this.securityLevel,
      this.encryptionKey});

  Vault.fromJson(Map<String, dynamic> storedData) {
    locked = storedData['locked'];
    path = storedData['path'];
    creationDate =
        DateTime.fromMillisecondsSinceEpoch(storedData['creation_date']);
    filesMetadataBankPath = storedData['files_metadata_bank_path'];
    name = storedData['name'];
    shouldDisconnectWhenVaultOpened =
        storedData['should_disconnect_when_vault_opened'];
    securityLevel = storedData['security_level'];
  }

  Map<String, dynamic> toJson() {
    return {
      'locked': locked,
      'path': path,
      'creation_date': creationDate.millisecondsSinceEpoch,
      'files_metadata_bank_path': filesMetadataBankPath,
      'name': name,
      'should_disconnect_when_vault_opened': shouldDisconnectWhenVaultOpened,
      'security_level': securityLevel,
    };
  }

  String toRawJson() {
    return jsonEncode(toJson());
  }

  /// If the vault is locked or not
  late bool locked;

  /// The path of the folder containing all the encrypted files
  late String path;

  /// When the vault has been created
  late DateTime creationDate;

  /// Where is the file who contains all encrypted files outer data like it's real creation date it's name and other things to restore when the chest is opened
  late String filesMetadataBankPath;

  /// The visual name of the chest
  late String name;

  /// Should the phone enter airplane mode when the chest is opened
  late bool shouldDisconnectWhenVaultOpened;

  /// The level of security the vault has
  late int securityLevel;

  /// The decryption key used to read files
  late SecretKey? encryptionKey;
}
