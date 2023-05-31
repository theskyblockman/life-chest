import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chest/file_exporter.dart';
import 'package:life_chest/vault.dart';

void main() {
  test('Export file then import it', () async {
    SecretKey secretKey = SecretKey('This is a secret key to test fil'.codeUnits); // This is a secret key to test file export/import
    Map<String, dynamic> metadata = {"ping": "pong"};
    List<int> decryptedFileContent = 'This is the file content, I do whatever I want'.codeUnits;
    List<int> encryptedFileContent = (await VaultsManager.cipher.encrypt(decryptedFileContent, secretKey: secretKey, nonce: Uint8List(VaultsManager.cipher.nonceLength))).cipherText;
    String unlockMethod = 'try and retry'; // The only unlock method

    List<int> exportedFile = await FileExporter.exportFile(md5RandomFileName(), secretKey, metadata, encryptedFileContent, unlockMethod);
    expect(FileExporter.isExportedFile(exportedFile), true);
    expect(FileExporter.determineExportedFileUnlockMethod(exportedFile), unlockMethod);
    expect(await FileExporter.testExportedFileEncryption(exportedFile, secretKey), true);
    expect(await FileExporter.testExportedFileEncryption(exportedFile, SecretKey('aaaa is a secret key to test fil'.codeUnits)), false);

    var importedFile = await FileExporter.importFile(exportedFile, secretKey);

    expect(mapEquals(importedFile!.$1, metadata), true);
    expect(importedFile.$2, decryptedFileContent);
  });
}