import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:life_chest/vault.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../file_explorer/file_placeholder.dart';

class SingleThreadedRecovery {
  /// Loads in memory the full decrypted content of [fileToRead] with [encryptionKey] and returns the decrypted data all at once
  static Future<Uint8List> loadAndDecryptFullFile(
      SecretKey encryptionKey, File fileToRead, Mac mac, [Chacha20? cipher, bool isTesting = false]) async {
    return Uint8List.fromList(await (cipher ?? VaultsManager.cipher).decrypt(
        SecretBox(fileToRead.readAsBytesSync(),
            nonce: isTesting ? Uint8List((cipher ?? VaultsManager.cipher).nonceLength) : base64Decode((await VaultsManager.nonceStorage.read(key: basename(fileToRead.path)))!), mac: mac),
        secretKey: encryptionKey));
  }

  /// Loads in memory the full decrypted content of [fileToRead] with [encryptionKey] and returns the decrypted data incrementally by data chunks
  static Future<Stream<List<int>>> loadAndDecryptFile(
      SecretKey encryptionKey, File fileToRead, Mac mac, [Chacha20? cipher, bool isTesting = false]) async {
    return (cipher ?? VaultsManager.cipher).decryptStream(fileToRead.openRead(),
        secretKey: encryptionKey,
        nonce: isTesting ? Uint8List((cipher ?? VaultsManager.cipher).nonceLength) : base64Decode((await VaultsManager.nonceStorage.read(key: basename(fileToRead.path)))!),
        mac: mac);
  }

  /// Selects the portion to decrypt and decrypts it (maybe the file reading part could be worked on)
  static Stream<List<int>> loadAndDecryptPartialFile(
      SecretKey encryptionKey,
      File fileToRead,
      int startByte,
      int endByte,
      Mac mac,
      [Chacha20? cipher, bool isTesting = false]) {
    int currentLength = startByte;
    return fileToRead.openRead(startByte, endByte).asyncMap((event) async {
      currentLength += event.length;
      return (cipher ?? VaultsManager.cipher).decrypt(SecretBox(event, nonce: isTesting ? Uint8List((cipher ?? VaultsManager.cipher).nonceLength) : base64Decode((await VaultsManager.nonceStorage.read(key: basename(fileToRead.path)))!), mac: mac),
          secretKey: encryptionKey,
          keyStreamIndex: currentLength - event.length);
    });
  }

  /// Encrypts the file in a specific location with the [encryptionKey] in the ChaCha20 algorithm
  static Future<(String, Map<String, dynamic>)?> saveFile(
      SecretKey encryptionKey,
      String vaultPath,
      String localPath,
      String? rootFolderPath,
      {File? createdFile,
      (Map<String, dynamic> metadata, List<int> data)? importedFile, bool isTesting = false}) async {
    String fileName = md5RandomFileName();
    File fileToCreate = File(join(vaultPath, fileName));
    await fileToCreate.create(recursive: true);
    Uint8List nonce = Uint8List.fromList(List.generate(VaultsManager.cipher.nonceLength, (index) => SecureRandom.safe.nextInt(256)));
    if(!isTesting) {
      await VaultsManager.nonceStorage.write(key: fileName, value: base64Encode(nonce));
    }


    Completer<List<int>> macReceiver = Completer();

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

    FileThumbnailsPlaceholder? placeholder = FileThumbnailsPlaceholder.getPlaceholderFromFileName(
        [finalData])[finalName];
    if (placeholder ==
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
    } else if (placeholder == FileThumbnailsPlaceholder.videos) {
      if (createdFile != null) {
        VideoData result = (await FlutterVideoInfo().getVideoInfo(createdFile.absolute.path))!;
        finalData['videoData'] = <String, dynamic>{};
        finalData['videoData']['width'] = result.width!;
        finalData['videoData']['height'] = result.height!;
        finalData['type'] = result.mimetype!;
      } else {
        finalData['videoData'] = importedFile!.$1.containsKey('videoData') ? importedFile.$1['videoData'] : {};
      }
    }

    if (createdFile != null) {
      IOSink fileToCreateSink = fileToCreate.openWrite();
      try {
        final clearTextStream = createdFile.openRead();
        final encryptedStream = (placeholder == FileThumbnailsPlaceholder.audio ? VaultsManager.secondaryCipher : VaultsManager.cipher).encryptStream(
            clearTextStream,
            secretKey: encryptionKey,
            nonce: nonce,
            onMac: (Mac mac) async {
              macReceiver.complete(mac.bytes);
            });
        await fileToCreateSink.addStream(encryptedStream);
      } finally {
        fileToCreateSink.close();
      }
    } else {
      SecretBox encryptedData = await (placeholder == FileThumbnailsPlaceholder.audio ? VaultsManager.secondaryCipher : VaultsManager.cipher).encrypt(
        importedFile!.$2,
        secretKey: encryptionKey,
        nonce: nonce,
      );
      fileToCreate.writeAsBytesSync(
          encryptedData.cipherText
      );
      macReceiver.complete(encryptedData.mac.bytes);
    }

    List<int> mac = await macReceiver.future;

    try {
      createdFile?.deleteSync(recursive: true);
    } catch (e) {
      // Ignore
    }

    finalData['mac'] = mac;

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
