import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
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

  static Future<List<int>> exportFile(
      String fileFakeName,
      SecretKey encryptionKey,
      Map<String, dynamic> fileMapData,
      List<int> encryptedFileContentToExport,
      String unlockMethodID,
      Map<String, dynamic> additionalUnlockData) async {
    List<int> finalExportedFile = [];

    // Signature
    finalExportedFile.addAll('Life Chest Encrypted File'.codeUnits);
    String encodedMetadata = jsonEncode(fileMapData);
    List<int> encryptedMetadata = (await VaultsManager.cipher.encrypt(
            utf8.encode(encodedMetadata),
            secretKey: encryptionKey,
            nonce: Uint8List(VaultsManager.cipher.nonceLength)))
        .cipherText;
    // The hash of the key to check if 2 files were encrypted using the same key (Always 64 chars long)
    finalExportedFile.addAll(sha256
        .convert(await encryptionKey.extractBytes())
        .toString()
        .codeUnits);

    // The unlock method of the file to use to find its secret key
    finalExportedFile.addAll(unlockMethodID.codeUnits);
    finalExportedFile.addAll('|'.codeUnits);

    // The additional unlock data which are required for biometrics for example
    finalExportedFile.addAll(jsonEncode(additionalUnlockData).codeUnits);
    finalExportedFile.addAll('|'.codeUnits);

    // The file metadata length so that no overflow can be made.
    finalExportedFile.addAll(encryptedMetadata.length.toString().codeUnits);
    finalExportedFile.addAll('|'.codeUnits);

    // The file fake name used internally by the app to identify it without giving its clear name, logically this isn't sensitive information so we can give the encrypted and clear file fake name so the app can say if a file is valid or not by detecting the "|" char and dividing the file name length by 2.
    finalExportedFile.addAll(fileFakeName.codeUnits);
    finalExportedFile.addAll((await VaultsManager.cipher.encrypt(
            fileFakeName.codeUnits,
            secretKey: encryptionKey,
            nonce: Uint8List(VaultsManager.cipher.nonceLength)))
        .cipherText);

    // The encrypted metadata
    finalExportedFile.addAll(encryptedMetadata);
    // The encrypted data file
    finalExportedFile.addAll(encryptedFileContentToExport);
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

    return finalExportedFile;
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
        nonce: Uint8List(VaultsManager.cipher.nonceLength), mac: Mac.empty);
    return listEquals(
        await VaultsManager.cipher
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
        .decode(await VaultsManager.cipher.decrypt(
            SecretBox(elements[3].sublist(64, 64 + metadataLength),
                nonce: Uint8List(VaultsManager.cipher.nonceLength),
                mac: Mac.empty),
            secretKey: encryptionKey))
        .codeUnits));

    List<int> fileData = await VaultsManager.cipher.decrypt(
        SecretBox(elements[3].sublist(64 + metadataLength),
            nonce: Uint8List(VaultsManager.cipher.nonceLength), mac: Mac.empty),
        secretKey: encryptionKey);

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
