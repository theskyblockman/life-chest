import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:life_chest/file_explorer/explorer_data.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/vault.dart';

class FileExporter {
  static List<List<int>> _splitListBySeparator(List<int> list, int separator,
      [int? maxLength]) {
    List<List<int>> result = [];
    List<int> currentList = [];

    for (int i = 0; i < list.length; i++) {
      int currentItem = list[i];

      if (currentItem == separator) {
        result.add(currentList);
        currentList = [];
      } else {
        currentList.add(currentItem);
      }
    }

    if (currentList.isNotEmpty) {
      result.add(currentList);
    }

    if (maxLength != null && result.length > maxLength) {
      Iterable<List<int>> resultToPutBackTogether =
          result.getRange(maxLength, result.length);
      List<int> newElement = [...result[maxLength - 1], separator];

      for (List<int> element in resultToPutBackTogether) {
        newElement.addAll(element);
        newElement.add(separator);
      }
      newElement.removeLast();
      result.removeRange(maxLength - 1, result.length);
      result.add(newElement);
    }

    return result;
  }

  static Future<void> exportFile(
      String fileFakeName,
      SecretKey encryptionKey,
      ThumbnailData data,
      Stream<List<int>> encryptedFile,
      String? filePath,
      String unlockMethodID,
      Map<String, dynamic> additionalUnlockData,
      StreamSink<List<int>> target,
      Uint8List? nonce,
      [bool isTesting = false]) async {
    // Signature
    target.add('Life Chest Encrypted File'.codeUnits);
    String encodedMetadata = jsonEncode(data.data);
    List<int> encryptedMetadata = (await VaultsManager.secondaryCipher.encrypt(
            utf8.encode(encodedMetadata),
            secretKey: encryptionKey,
            nonce: Uint8List(VaultsManager.secondaryCipher.nonceLength)))
        .cipherText;
    // The hash of the key to check if 2 files were encrypted using the same key (Always 64 chars long)
    target.add(sha256
        .convert(await encryptionKey.extractBytes())
        .toString()
        .codeUnits);

    // The unlock method of the file to use to find its secret key
    target.add(unlockMethodID.codeUnits);
    target.add('|'.codeUnits);

    // The additional unlock data which are required for biometrics for example
    target.add(jsonEncode(additionalUnlockData).codeUnits);
    target.add('|'.codeUnits);

    // The file metadata length so that no overflow can be made.
    target.add(encryptedMetadata.length.toString().codeUnits);
    target.add('|'.codeUnits);

    // The file fake name used internally by the app to identify it without giving its clear name, logically this isn't sensitive information so we can give the encrypted and clear file fake name so the app can say if a file is valid or not by detecting the "|" char and dividing the file name length by 2.
    target.add(fileFakeName.codeUnits);
    target.add((await VaultsManager.secondaryCipher.encrypt(
            fileFakeName.codeUnits,
            secretKey: encryptionKey,
            nonce: Uint8List(VaultsManager.cipher.nonceLength)))
        .cipherText);

    // The encrypted metadata
    target.add(encryptedMetadata);

    print('adding stream');

    print('mac: ${data.data['mac']}');

    var stream = (await SingleThreadedRecovery.decryptStream(
        encryptionKey, encryptedFile, Mac(List<int>.from(data.data['mac'])),
        filePath: filePath, nonce: nonce, isTesting: isTesting));
    print('finished loading stream');

    // The encrypted data file
    await target.addStream(stream);
    print('stream added');

    await target.close();
    print('stream closed');
    /*
    Im sum, the file structure is:
    - Signature (Life Chest Encrypted File)
    - Key SHA256 hash
    - Unlock method
    - Separator (|)
    - Additional unlock data
    - Separator (|)
    - Metadata length
    - Separator (|)
    - Decrypted file fake name
    - Encrypted file fake name
    - Metadata
    - File encrypted data

    This way the file can be securely shared
    */
  }

  static String? determineExportedFileUnlockMethod(List<int> exportedFile) {
    if (!isExportedFile(exportedFile)) return null;
    List<List<int>> elements =
        _splitListBySeparator(exportedFile.sublist(25), '|'.codeUnits[0], 4);
    return String.fromCharCodes(elements[0].sublist(64));
  }

  static List<int>? getFileKeyHash(List<int> exportedFile) {
    if (!isExportedFile(exportedFile)) return null;
    List<List<int>> elements =
        _splitListBySeparator(exportedFile.sublist(25), '|'.codeUnits[0], 4);
    return elements[0].sublist(0, 64);
  }

  static Future<bool?> testExportedFileEncryption(
      List<int> exportedFile, SecretKey encryptionKey) async {
    if (!isExportedFile(exportedFile)) return null;
    List<List<int>> elements =
        _splitListBySeparator(exportedFile, '|'.codeUnits[0], 4);
    // No need to round, the length is even whatever happening because of the source multiplication by 2 rule
    SecretBox encryptedName = SecretBox(List.from(elements[3].sublist(32, 64)),
        nonce: Uint8List(VaultsManager.secondaryCipher.nonceLength),
        mac: Mac.empty);
    return listEquals(
        await VaultsManager.secondaryCipher
            .decrypt(encryptedName, secretKey: encryptionKey),
        elements[3].sublist(0, 32));
  }

  static Future<
          (Map<String, dynamic> fileMetadata, List<int> decryptedContent)?>
      importFile(List<int> exportedFile, SecretKey encryptionKey) async {
    if (await testExportedFileEncryption(exportedFile, encryptionKey) != true) {
      return null;
    }
    List<List<int>> elements =
        _splitListBySeparator(exportedFile, '|'.codeUnits[0], 4);

    int metadataLength = int.parse(String.fromCharCodes(elements[2]));

    Map<String, dynamic> metadata = jsonDecode(String.fromCharCodes(utf8
        .decode(await VaultsManager.secondaryCipher.decrypt(
            SecretBox(elements[3].sublist(64, 64 + metadataLength),
                nonce: Uint8List(VaultsManager.secondaryCipher.nonceLength),
                mac: Mac.empty),
            secretKey: encryptionKey))
        .codeUnits));

    List<int> fileData = await VaultsManager.cipher.decrypt(
        SecretBox(elements[3].sublist(64 + metadataLength),
            nonce: metadata.containsKey('nonce')
                ? base64Decode(metadata['nonce'])
                : Uint8List(VaultsManager.secondaryCipher.nonceLength),
            mac: Mac(List.from(metadata['mac']))),
        secretKey: encryptionKey);

    metadata.remove('nonce');

    return (metadata, fileData);
  }

  static bool isExportedFile(List<int> fileContent) {
    return fileContent.length >= 25 &&
        listEquals(
            'Life Chest Encrypted File'.codeUnits, fileContent.sublist(0, 25));
  }

  static Map<String, dynamic>? getAdditionalUnlockData(List<int> fileContent) {
    if (!isExportedFile(fileContent)) return null;

    List<List<int>> elements =
        _splitListBySeparator(fileContent, '|'.codeUnits[0], 4);

    return jsonDecode(String.fromCharCodes(elements[1]));
  }
}
