import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class SingleThreadedRecovery {
  static Future<Uint8List> loadAndDecryptFullFile(
      SecretKey encryptionKey, File fileToRead) async {
    return Uint8List.fromList(await VaultsManager.cipher.decrypt(
        SecretBox(fileToRead.readAsBytesSync(),
            nonce: Uint8List(VaultsManager.cipher.nonceLength), mac: Mac.empty),
        secretKey: encryptionKey));
  }

  static Stream<List<int>> loadAndDecryptFile(
      SecretKey encryptionKey, File fileToRead) {
    return VaultsManager.cipher.decryptStream(fileToRead.openRead(),
        secretKey: encryptionKey, nonce: Uint8List(32), mac: Mac.empty);
  }

  static Future<Map<String, String>?> saveFiles(
      SecretKey encryptionKey, String vaultPath,
      {List<File>? filesToSave,
      String dialogTitle = 'Pick the files you want to add'}) async {
    if (filesToSave == null) {
      FilePickerResult? pickedFiles = await FilePicker.platform
          .pickFiles(allowMultiple: true, dialogTitle: dialogTitle);
      if (pickedFiles != null) {
        filesToSave = [
          for (PlatformFile file in pickedFiles.files) File(file.path!)
        ];
      } else {
        return null;
      }
    }

    final Map<String, String> additionalFiles = {};

    for (File createdFile in filesToSave) {
      String fileName = md5RandomFileName();
      File fileToCreate = File(join(vaultPath, fileName));
      await fileToCreate.create(recursive: true);
      IOSink fileToCreateSink = fileToCreate.openWrite();
      try {
        final clearTextStream = createdFile.openRead();
        final encryptedStream = VaultsManager.cipher.encryptStream(
            clearTextStream,
            secretKey: encryptionKey,
            nonce: Uint8List(VaultsManager.cipher.nonceLength),
            onMac: (Mac mac) {});
        await fileToCreateSink.addStream(encryptedStream);
      } finally {
        fileToCreateSink.close();
        additionalFiles[fileName] = basename(createdFile.path);
      }
    }
    return additionalFiles;
  }
}
