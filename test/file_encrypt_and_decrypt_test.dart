import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:path/path.dart';

void main() async {
  (String, Map<String, dynamic>)? savedData;
  SecretKey secretKey = SecretKey('This is a secret key to test fil'
      .codeUnits); // This is a secret key to test file encryption/decryption
  test('Encrypt a file', () async {
    expect(File('./test/assets/file_to_clone').existsSync(), isTrue, reason: 'file_to_clone does not exists in the assets folder in the tests');

    File fileToClone = File('./test/assets/file_to_clone');
    File clonedFile = File('./test/assets/cloned_file');

    if(clonedFile.existsSync()) clonedFile.deleteSync();
    clonedFile.createSync();

    clonedFile.writeAsBytesSync(fileToClone.readAsBytesSync());

    savedData = await SingleThreadedRecovery.saveFile(secretKey, './test/assets/', '', '/', createdFile: clonedFile);


  });

  test('Decrypts partially a file', () async {
    if(savedData == null) {
      Directory assetsDirectory = Directory('./test/assets/');
      expect(assetsDirectory.existsSync() && assetsDirectory.listSync().isNotEmpty, isTrue, reason: 'The first test hasn\'t been ran once');

      savedData = (basename(assetsDirectory.listSync().first.path), {});
    }


    File savedFile = File(join('test', 'assets', savedData!.$1));
    List<int> fullFileDecryption = await SingleThreadedRecovery.loadAndDecryptFullFile(secretKey, savedFile);
    List<int> partialFileDecryption = List.empty(growable: true);

    Completer completer = Completer();

    int fileLength = savedFile.lengthSync();
    int fileStart = Random().nextInt(fileLength);
    fileStart = fileStart == 0 ? 1 : fileStart;
    SingleThreadedRecovery.loadAndDecryptPartialFile(secretKey, savedFile, fileStart, savedFile.lengthSync()).listen((event) {
      partialFileDecryption.addAll(event);
    }, onDone: () => completer.complete());

    await completer.future;

    for(int i = 0; i < fileLength; i++) {
      //ignore: avoid_print
      print('$i : ${fullFileDecryption.elementAtOrNull(i) ?? 'NOT FOUND'} : ${i - fileStart < 0 ? 'NOT FOUND' : partialFileDecryption.elementAtOrNull(i - fileStart) ?? 'NOT FOUND'}');
    }
    //ignore: avoid_print
    print('Full length: ${fullFileDecryption.length} Partial length: ${partialFileDecryption.length} File Start: $fileStart}');

    expect(listEquals(fullFileDecryption.sublist(fileStart), partialFileDecryption), isTrue);
  });
}