import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:life_chest/vault.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../file_explorer/file_placeholder.dart';

class SingleThreadedRecovery {
  /// Loads in memory the full decrypted content of [fileToRead] with [encryptionKey] and returns the decrypted data all at once
  static Future<Uint8List> loadAndDecryptFullFile(
      SecretKey encryptionKey, File fileToRead) async {
    return Uint8List.fromList(await VaultsManager.cipher.decrypt(
        SecretBox(fileToRead.readAsBytesSync(),
            nonce: Uint8List(VaultsManager.cipher.nonceLength), mac: Mac.empty),
        secretKey: encryptionKey));
  }

  /// Loads in memory the full decrypted content of [fileToRead] with [encryptionKey] and returns the decrypted data incrementally by data chunks
  static Stream<List<int>> loadAndDecryptFile(
      SecretKey encryptionKey, File fileToRead) {
    return VaultsManager.cipher.decryptStream(fileToRead.openRead(),
        secretKey: encryptionKey,
        nonce: Uint8List(VaultsManager.cipher.nonceLength),
        mac: Mac.empty);
  }

  /// Selects the portion to decrypt and decrypts it (maybe the file reading part could be worked on)
  static Future<Stream<List<int>>> loadAndDecryptPartialFile(
      SecretKey encryptionKey,
      File fileToRead,
      int startByte,
      int endByte) async {
    return VaultsManager.cipher.decryptStream(
        fileToRead.openRead(startByte, endByte),
        mac: Mac.empty,
        secretKey: encryptionKey,
        nonce: Uint8List(VaultsManager.cipher.nonceLength));
  }

  /// Encrypts the file in a specific location with the [encryptionKey] in the ChaCha20 algorithm
  static Future<(String, Map<String, dynamic>)?> saveFile(
      SecretKey encryptionKey,
      String vaultPath,
      String localPath,
      String? rootFolderPath,
      {File? createdFile,
      (Map<String, dynamic> metadata, List<int> data)? importedFile}) async {
    String fileName = md5RandomFileName();
    File fileToCreate = File(join(vaultPath, fileName));
    await fileToCreate.create(recursive: true);
    if (createdFile != null) {
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
      }
    } else {
      fileToCreate.writeAsBytesSync(
          (await VaultsManager.cipher.encrypt(
              importedFile!.$2,
            secretKey: encryptionKey,
              nonce: Uint8List(VaultsManager.cipher.nonceLength),
          )).cipherText
          );
    }

    String? type;

    if (createdFile != null) {
      type = lookupMimeType(basename(createdFile.path),
              headerBytes: createdFile.readAsBytesSync()) ??
          '*/*';
    } else {
      type = importedFile!.$1['type'];
    }

    String finalName = join(
        localPath,
        rootFolderPath == null
            ? basename(createdFile != null
                ? createdFile.path
                : importedFile!.$1['name'])
            : createdFile != null
                ? relative(createdFile.path, from: rootFolderPath)
                : relative(importedFile!.$1['name'], from: rootFolderPath));
    Map<String, dynamic> finalData = {'name': finalName, 'type': type};
    if (FileThumbnailsPlaceholder.getPlaceholderFromFileName(
            [finalData])[finalName] ==
        FileThumbnailsPlaceholder.audio) {
      if (createdFile != null) {
        Metadata foundData = await MetadataRetriever.fromFile(createdFile);
        finalData['audioData'] = foundData.toJson();
        finalData['audioData']['trackCover'] = foundData.albumArt != null
            ? base64.encode(foundData.albumArt!)
            : null;
        finalData['audioData']['initialSize'] = createdFile.lengthSync();
        finalData['type'] = foundData.mimeType;
      } else {
        finalData['audioData'] = importedFile!.$1['audioData'];
      }
    }

    try {
      createdFile?.deleteSync(recursive: true);
    } catch (e) {
      // Ignore
    }

    return (fileName, finalData);
  }

  /// Encrypts multiple files at once
  /// see [saveFile]
  static Future<Map<String, Map<String, dynamic>>?> saveFiles(
      SecretKey encryptionKey, String vaultPath, String localPath,
      {List<File>? filesToSave,
      String dialogTitle = 'Pick the files you want to add',
      String? rootFolderPath}) async {
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

    final Map<String, Map<String, dynamic>> additionalFiles = {};

    for (File createdFile in filesToSave) {
      (String, Map<String, dynamic>) savedFile = (await saveFile(
          encryptionKey, vaultPath, localPath, rootFolderPath,
          createdFile: createdFile))!;
      additionalFiles[savedFile.$1] = savedFile.$2;
    }
    return additionalFiles;
  }

  /// Opens the system dialog to pick the files to save and probably encrypt.
  static Future<List<File>?> pickFilesToSave(
      {String dialogTitle = 'Pick the files you want to add'}) async {
    FilePickerResult? pickedFiles = await FilePicker.platform
        .pickFiles(allowMultiple: true, dialogTitle: dialogTitle);

    return pickedFiles != null
        ? [for (PlatformFile file in pickedFiles.files) File(file.path!)]
        : null;
  }

  /// Opens the system dialog to pick a folder to save and probably encrypt (inner files included)
  static Future<Directory?> pickFolderToSave(
      {String dialogTitle = 'Pick the folder you want to add'}) async {
    String? folderPath =
        await FilePicker.platform.getDirectoryPath(dialogTitle: dialogTitle);
    return folderPath != null ? Directory(folderPath) : null;
  }

  /// Incrementally save files provided, with the [encryptionKey] and returns its map value
  static Stream<(String, Map<String, dynamic>)> progressivelySaveFiles(
      SecretKey encryptionKey, String vaultPath, String localPath,
      {List<File>? filesToSave,
      List<(Map<String, dynamic> metadata, List<int> data)>?
          importedFilesToSave,
      String? rootFolderPath}) async* {
    if (filesToSave != null) {
      for (File createdFile in filesToSave) {
        yield (await saveFile(
            encryptionKey, vaultPath, localPath, rootFolderPath,
            createdFile: createdFile))!;
      }
    } else {
      for ((Map<String, dynamic> metadata, List<int> data) importedFile
          in importedFilesToSave!) {
        yield (await saveFile(
            encryptionKey, vaultPath, localPath, rootFolderPath,
            importedFile: importedFile))!;
      }
    }
  }
}
