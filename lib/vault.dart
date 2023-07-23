import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_explorer/file_sort_methods.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

class PermissionError extends Error {
  final String message;

  PermissionError(this.message);

  @override
  String toString() => message;
}

/// The class that manages the core element of the app: chests (or vault, the name is still to determine)
class VaultsManager {
  static List<Vault> storedVaults = [];
  static late final String appFolder;
  static late final File mainConfigFile;
  static late final PackageInfo packageInfo;
  static final cipher = Chacha20.poly1305Aead();
  static final secondaryCipher = Chacha20(macAlgorithm: MacAlgorithm.empty); // Mainly used for file exportation so that no MAC is required.
  static bool shouldUpdateVaultList = false;
  static Map<String, dynamic> globalAdditionalUnlockData = {};
  static late final FlutterSecureStorage nonceStorage;

  static void saveVaults() {
    mainConfigFile.writeAsStringSync(jsonEncode({
      "chests": [for (Vault vault in storedVaults) vault.toJson()],
      "current_sort_method": FileExplorerState.currentSortMethod.id,
      "global_authentication_additional_data": globalAdditionalUnlockData
    }));

    for (Vault vault in storedVaults) {
      File recognizerFile = File(vault.filesMetadataBankPath);
      recognizerFile.createSync(recursive: true);
      recognizerFile.writeAsStringSync(vault.toRawJson());
    }
  }

  static void loadVaults() async {
    late Map<String, dynamic> chests;

    try {
      chests = jsonDecode(mainConfigFile.readAsStringSync());
      FileExplorerState.currentSortMethod =
          FileSortMethod.fromID(chests['current_sort_method']!)!;
    } on FormatException {
      chests = jsonDecode(await rootBundle
          .loadString('file_settings/default_config.json', cache: false));
    }

    List<Vault> constructedVaults = [];
    for (Map<String, dynamic> chest in chests['chests']) {
      constructedVaults.add(Vault.fromJson(chest));
    }
    storedVaults = constructedVaults;
    
    globalAdditionalUnlockData = chests["global_authentication_additional_data"] ?? {};
  }

  static Future<Vault> createVaultFromPolicy(VaultPolicy policy) async {
    String path = p.join(VaultsManager.appFolder, '.${md5RandomFileName()}');
    // Do not edit the witness test file.
    File keyFile = File(p.join(path, '.witness'));
    keyFile.createSync(recursive: true);
    SecretKey cryptKey = policy.key!;
    // NOTE: An IV is not needed here as the first block of an encryption won't really matter because the data structure generated by this app is known.
    SecretBox encryptedWitnessFile = await cipher.encrypt(
        utf8.encode(await rootBundle
            .loadString('file_settings/encryption_witness_file', cache: false)),
        secretKey: cryptKey,
        nonce: Uint8List(cipher.nonceLength));

    await nonceStorage.write(key: keyFile.absolute.path, value: base64Encode(encryptedWitnessFile.mac.bytes));

    File witnessFile = File(p.join(path, '.witness'));
    witnessFile.createSync(recursive: true);
    witnessFile.writeAsBytesSync(encryptedWitnessFile.cipherText);

    Vault createdVault = Vault(
        locked: false,
        creationDate: DateTime.now(),
        filesMetadataBankPath: p.join(path, '.${md5RandomFileName()}'),
        path: path,
        name: policy.vaultName,
        securityLevel: policy.securityLevel,
        encryptionKey: cryptKey,
        unlockMechanismType: policy.unlockType,
    );

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
                nonce: Uint8List(cipher.nonceLength), mac: Mac(base64Decode((await nonceStorage.read(key: witnessFile.absolute.path))!))),
            secretKey: vault.encryptionKey!),
        allowMalformed: true);
    return decryptedWitnessFile ==
        await rootBundle.loadString('file_settings/encryption_witness_file',
            cache: false);
  }

  static Map<String, dynamic> constructMap(Vault vault,
      {Map<String, dynamic>? oldMap,
      Map<String, Map<String, dynamic>>? additionalFiles}) {
    Map<String, dynamic> newMap = {};
    oldMap ??= {};
    additionalFiles ??= {};
    for (FileSystemEntity file in Directory(vault.path).listSync()) {
      String localPath = file.path.substring(vault.path.length + 1);

      if (localPath.startsWith('.')) continue;

      newMap[localPath] = {'name': 'unknown', 'type': '*/*'};
    }

    for (MapEntry<String, dynamic> oldFile in oldMap.entries.toList()
      ..addAll(additionalFiles.entries)) {
      if (newMap[oldFile.key] != null || oldFile.value['type'] == 'folder') {
        newMap[oldFile.key] = oldFile.value;
      }
    }
    return newMap;
  }

  static Future<List<int>?> encryptMap(
      Vault vault, Map<String, dynamic> initialMap) async {
    if (vault.encryptionKey == null) return null;

    SecretBox encryptedMap = (await cipher.encrypt(utf8.encode(jsonEncode(initialMap)),
        secretKey: vault.encryptionKey!,
        nonce: Uint8List(cipher.nonceLength)));

    await nonceStorage.write(key: vault.filesMetadataBankPath, value: base64Encode(encryptedMap.mac.bytes));

    return encryptedMap.cipherText;
  }

  static Future<Map<String, dynamic>?> decryptMap(
      Vault vault, List<int> encryptedMap) async {
    if (vault.encryptionKey == null) return null;
    Map<String, dynamic> decryptedMap = jsonDecode(utf8.decode(
        await cipher.decrypt(
            SecretBox(encryptedMap,
                nonce: Uint8List(cipher.nonceLength), mac: Mac(base64Decode((await nonceStorage.read(key: vault.filesMetadataBankPath))!))),
            secretKey: vault.encryptionKey!)));

    return decryptedMap;
  }
}

class VaultPolicy {
  bool isInternalVault;
  String vaultName;
  Map<String, dynamic> vaultUnlockAdditionalData;
  int securityLevel;
  SecretKey? key;
  String unlockType;

  VaultPolicy(
      {this.isInternalVault = true,
      this.vaultName = 'Unnamed vault',
      required this.vaultUnlockAdditionalData,
      this.securityLevel = 2,
      this.unlockType = 'password',
      this.key});
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
      required this.securityLevel,
      required this.unlockMechanismType,
      this.encryptionKey}) : lastVersionCode = int.parse(VaultsManager.packageInfo.buildNumber);

  Vault.fromJson(Map<String, dynamic> storedData) {
    locked = storedData['locked'];
    path = storedData['path'];
    creationDate =
        DateTime.fromMillisecondsSinceEpoch(storedData['creation_date']);
    filesMetadataBankPath = storedData['files_metadata_bank_path'];
    name = storedData['name'];
    securityLevel = storedData['security_level'];
    unlockMechanismType = storedData['unlock_mechanism_type'] ?? 'password';
    additionalUnlockData = storedData['additional_unlock_data'] ?? {};
    if(storedData.containsKey('last_version_code')) {
      lastVersionCode = storedData['last_version_code'];
    } else {
      PackageInfo.fromPlatform().then((value) {
        lastVersionCode = int.parse(value.buildNumber);
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'locked': locked,
      'path': path,
      'creation_date': creationDate.millisecondsSinceEpoch,
      'files_metadata_bank_path': filesMetadataBankPath,
      'name': name,
      'security_level': securityLevel,
      'unlock_mechanism_type': unlockMechanismType,
      'additional_unlock_data': additionalUnlockData,
      'last_version_code': lastVersionCode,
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

  /// The level of security the vault has
  late int securityLevel;

  /// The decryption key used to read files
  late SecretKey? encryptionKey;

  /// The type of mechanism to use to create a key to unlock the vault
  late String unlockMechanismType;

  /// Any data needed to generate a key to unlock the vault.
  late Map<String, dynamic> additionalUnlockData;

  /// The version code of the app that the chest is currently used, this could bw used to upgrade it to a new security standard.
  late int lastVersionCode;
}
