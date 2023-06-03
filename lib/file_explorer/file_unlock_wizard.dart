import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/file_recovery/file_exporter.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/unlock_tester.dart';
import 'package:path/path.dart';

class FileUnlockWizard extends StatefulWidget {
  const FileUnlockWizard({super.key, required this.filesToDecrypt});

  final List<File> filesToDecrypt;

  @override
  State<StatefulWidget> createState() => FileUnlockWizardState();
}

class FileUnlockWizardState extends State<FileUnlockWizard> {
  Map<List<int>, (List<List<int>> fileContents, SecretKey? key)> currentStatus =
      {};
  Map<List<int>, (Map<String, dynamic> metadata, List<int> data)> unlockedMap =
      {};

  Future<(Map<String, dynamic> metadata, List<int> data)> getOrUnlockFile(
      List<int> fileToUnlock, SecretKey key) async {
    for (List<int> unlockedFile in unlockedMap.keys) {
      if (listEquals(fileToUnlock, unlockedFile)) {
        return unlockedMap[unlockedFile]!;
      }
    }

    unlockedMap[fileToUnlock] =
        (await FileExporter.importFile(fileToUnlock, key))!;

    return unlockedMap[fileToUnlock]!;
  }

  @override
  void initState() {
    super.initState();
    for (File fileToDecrypt in widget.filesToDecrypt) {
      List<int> fileContent = fileToDecrypt.readAsBytesSync();

      List<int> currentHashKey = FileExporter.getFileKeyHash(fileContent)!;
      if (currentStatus.isEmpty) {
        currentStatus[currentHashKey] = ([fileContent], null);
      } else {
        bool fileAdded = false;
        for (List<int> fileHash in currentStatus.keys) {
          if (listEquals(fileHash, currentHashKey)) {
            currentStatus[fileHash]!.$1.add(fileContent);
            fileAdded = true;
            break;
          }
          if (!fileAdded) {
            currentStatus[currentHashKey] = ([fileContent], null);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map reverseMap(Map map) => {for (var e in map.entries) e.value: e.key};

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).unlockWizard)),
      floatingActionButton: FilledButton(onPressed: List<(List<List<int>> fileContents, SecretKey? key)>.from(currentStatus.values).any((element) => element.$2 != null) ? () {
        Navigator.pop(context, List<(Map<String, dynamic> metadata, List<int> data)>.from(unlockedMap.values));
      } : null, child: Text(S.of(context).import)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Wrap(
            spacing: 15,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: [
              for (List<int> fileGroup in currentStatus.keys)
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(children: [
                    Card(
                        child: ListTile(
                      title: Text(
                          S.of(context).group(List.from(currentStatus.keys).indexOf(fileGroup) + 1)),
                      subtitle: Text(S.of(context).unlockAbleBy(reverseMap(UnlockMechanism.unlockMechanisms)[FileExporter.determineExportedFileUnlockMethod(currentStatus[fileGroup]!.$1[0])!]!((SecretKey key, bool check) => null).getName(context))),
                      trailing: currentStatus[fileGroup]!.$2 == null ? const Icon(Icons.key) : IconButton(onPressed: () {
                        setState(() {
                          currentStatus[fileGroup] = (currentStatus[fileGroup]!.$1, null);
                        });
                      }, icon: const Icon(Icons.close)),
                          onTap: () {
                            UnlockTester tester = UnlockTester(FileExporter.determineExportedFileUnlockMethod(currentStatus[fileGroup]!.$1[0])!,
                                FileExporter.getAdditionalUnlockData(currentStatus[fileGroup]!.$1[0])!,
                                onKeyIssued: (issuedKey, didPushed) =>
                                    onKeyIssued(context, fileGroup, issuedKey, didPushed));

                            tester.shouldUseChooser(context);
                          },
                    )),
                    for (List<int> fileToDecrypt in currentStatus[fileGroup]!.$1)
                      FutureBuilder(
                          initialData: ({'name': 'Unknown file'}, []),
                          future: currentStatus[fileGroup]!.$2 == null
                              ? Future.value(({'name': 'Unknown file'}, []))
                              : getOrUnlockFile(
                                  fileToDecrypt, currentStatus[fileGroup]!.$2!),
                          builder: (context, snapshot) {
                            return ListTile(
                                title: Text(basename(snapshot.data!.$1['name'])),
                                subtitle: snapshot.data!.$2.isEmpty
                                    ? Text(S.of(context).exportedFileDescription)
                                    : null);
                          }),
                  ]),
                )
            ]),
      ),
    );
  }

  void onKeyIssued(BuildContext context, List<int> keyHash, SecretKey issuedKey, bool didPush) async {
    if (context.mounted && didPush) {
      Navigator.pop(context);
    }
    for (List<int> unlockedFile in currentStatus.keys) {
      if (listEquals(keyHash, unlockedFile)) {
        if(await FileExporter.testExportedFileEncryption(currentStatus[unlockedFile]!.$1[0], issuedKey) == true) {
          setState(() {
            currentStatus[unlockedFile] = (currentStatus[unlockedFile]!.$1, issuedKey);
          });

          break;
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).wrongPassword))
          );

          return;
        }
      }
    }
  }
}

