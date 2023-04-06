import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

@Deprecated('Use NativeRecovery instead')
class MultithreadedRecovery {
  static void _decryptFileBlock(List<dynamic> args) async {
    Encrypter cipher = args[0];
    SendPort comPort = args[1];
    Encrypted block = args[2];
    int blockID = args[3];

    comPort.send(MapEntry(blockID, Uint8List.fromList(cipher.decryptBytes(block, iv: IV.fromLength(16)))));
  }

  static void _startMultithreadedDecryption(List<dynamic> args) async {
    final Key encryptionKey = args[0];
    final File fileToRead = args[1];
    final SendPort port = args[2];
    final ReceivePort decryptPort = ReceivePort();
    Encrypter cipher = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
    List<String> base64Blocks = fileToRead.readAsLinesSync();
    List<Encrypted> encryptedBlocks = List.generate(base64Blocks.length, (index) {
      return Encrypted.fromBase64(base64Blocks[index]);
    });

    for(Encrypted encryptedBlock in encryptedBlocks) {
      await Isolate.spawn(_decryptFileBlock, [
        cipher,
        decryptPort.sendPort,
        encryptedBlock,
        encryptedBlocks.indexOf(encryptedBlock)
      ]);
    }
    List<Uint8List> decryptedBlocks = List.generate(encryptedBlocks.length, (index) => Uint8List(0));
    int receivedBlocksAmount = 0;
    decryptPort.listen((message) {
      MapEntry<int, Uint8List> msg = message;
      decryptedBlocks[msg.key] = msg.value;
      receivedBlocksAmount++;
      if(receivedBlocksAmount == encryptedBlocks.length) {
        List<int>? finalFile;
        for(Uint8List decryptedRawBlock in decryptedBlocks) {
          List<int> decryptedBlock = decryptedRawBlock.toList();
          if(finalFile == null) {
            finalFile = decryptedBlock;
            continue;
          }
          finalFile.addAll(decryptedBlock);
        }

        port.send(Uint8List.fromList(finalFile!));
      }
    });
  }
  
  static Future<Uint8List> loadAndDecryptFile(Key encryptionKey, File fileToRead) async {
    ReceivePort dataPort = ReceivePort();
    Isolate.spawn(_startMultithreadedDecryption, [encryptionKey, fileToRead, dataPort.sendPort]);

    return await dataPort.first;
  }

  static List<List<T>> _splitList<T>(List<T> list, int numSublists) {
    int sublistLength = list.length ~/ numSublists;
    int remainingItems = list.length % numSublists;
    List<List<T>> sublists = [];
    int offset = 0;
    for (int i = 0; i < numSublists; i++) {
      int length = sublistLength + (i < remainingItems ? 1 : 0);
      sublists.add(list.sublist(offset, offset + length));
      offset += length;
    }
    return sublists;
  }
  
  static Future<Map<String, String>?> saveFilesForMultithreadedDecryption(Key encryptionKey, String vaultPath, {List<File> filesToSave = const [], String dialogTitle = 'Pick the files you want to add', int threadCount = 3, int blocksCount = 3}) async {
    if(filesToSave.isEmpty) {
      FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(allowMultiple: true, dialogTitle: dialogTitle);
      if(pickedFiles != null) {
        filesToSave = [
            for(PlatformFile file in pickedFiles.files)
              File(file.path!)
          ];
      } else {
        return null;
      }
    }

    List<List<File>> assignableFiles = _splitList(filesToSave, threadCount);

    final ReceivePort port = ReceivePort();
    final Encrypter cipher = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
    final Map<String, String> additionalFiles = {};
    int aliveThreads = threadCount;
    final Completer<void> completer = Completer<void>();

    Future<void> listenForMessages() async {
      await for (var message in port) {
        additionalFiles.addAll(message);
        aliveThreads--;
        if (aliveThreads == 0) {
          completer.complete();
          port.close();
        }
      }
    }

    listenForMessages();
    
    
    for(List<File> threadFiles in assignableFiles) {
      await Isolate.spawn(_saveAndEncryptFiles, [threadFiles, cipher, vaultPath, port.sendPort, blocksCount]);
    }

    await completer.future; // Wait for all the tasks to finish

    return additionalFiles;
  }

  static String _joinByNewLine(List<String> lines) {
    String finalString = '';

    for(String line in lines) {
      finalString += line;
      finalString += '\n';
    }
    finalString.trim();

    return finalString;
  }

  static void _saveAndEncryptFiles(List<dynamic> args) async {
    List<File> pickedFiles = args[0];
    Encrypter cipher = args[1];
    Map<String, String> additionalFiles = {};
    String vaultPath = args[2];
    SendPort port = args[3];
    int blocksAmount = args[4];

    for(File createdFile in pickedFiles) {
      String fileName = md5RandomFileName();
      File fileToCreate = File(join(vaultPath, fileName));
      await fileToCreate.create(recursive: true);
      List<List<int>> decryptedBlocks = _splitList(await createdFile.readAsBytes(), blocksAmount);
      List<String> encryptedBlocks = [];
      for(List<int> decryptedBlock in decryptedBlocks) {
        encryptedBlocks.add(cipher.encryptBytes(decryptedBlock, iv: IV.fromLength(16)).base64);
      }
      await fileToCreate.writeAsString(_joinByNewLine(encryptedBlocks));
      additionalFiles[fileName] = basename(createdFile.path);
    }
    port.send(additionalFiles);
  }
}