import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chest/file_recovery/file_exporter.dart';
import 'package:life_chest/vault.dart';

void main() {
  test('Export file then import it', () async {
    SecretKey secretKey = SecretKey('This is a secret key to test fil'
        .codeUnits); // This is a secret key to test file export/import
    Map<String, dynamic> metadata = {"ping": "pong"};
    List<int> decryptedFileContent =
        'This is the file content, | \'\' I do whatever I want'.codeUnits;
    SecretBox secretBox = (await VaultsManager.cipher.encrypt(
        decryptedFileContent,
        secretKey: secretKey,
        nonce: Uint8List(VaultsManager.cipher.nonceLength)));
    List<int> encryptedFileContent = secretBox.cipherText;
    String unlockMethod = 'try and retry'; // The only unlock method
    print('encrypted file content: $encryptedFileContent');

    StreamController<List<int>> writerController =
        StreamController<List<int>>();

    var fileName = md5RandomFileName();
    await FileExporter.exportFile(
        fileName,
        secretKey,
        MapEntry(fileName, <String, dynamic>{'mac': secretBox.mac.bytes}),
        Stream.value(encryptedFileContent),
        null,
        unlockMethod,
        {},
        writerController.sink,
        Uint8List.fromList(secretBox.nonce),
        true);

    List<int> exportedFile = await writerController.stream.fold<List<int>>(
        <int>[],
        (List<int> previous, List<int> element) => previous..addAll(element));

    expect(FileExporter.isExportedFile(exportedFile), true);
    expect(FileExporter.determineExportedFileUnlockMethod(exportedFile),
        unlockMethod);
    expect(
        await FileExporter.testExportedFileEncryption(exportedFile, secretKey),
        true);
    expect(
        await FileExporter.testExportedFileEncryption(exportedFile,
            SecretKey('aaaa is a secret key to test fil'.codeUnits)),
        false);

    var importedFile = await FileExporter.importFile(exportedFile, secretKey);

    expect(mapEquals(importedFile!.$1, metadata), true);
    expect(importedFile.$2, decryptedFileContent);
  });
}
