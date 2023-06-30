import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/file_explorer/file_unlock_wizard.dart';
import 'package:life_chest/file_recovery/file_exporter.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:life_chest/file_explorer/file_sort_methods.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_explorer/file_thumbnail.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The file reader, this enable the user to see file and to browse between them while keeping a cache of them
class FileReader extends StatefulWidget {
  final List<FileThumbnail> Function() thumbnails;
  final Vault fileVault;
  final int initialThumbnail;

  const FileReader(
      {super.key,
      required this.thumbnails,
      required this.fileVault,
      required this.initialThumbnail});

  @override
  State<StatefulWidget> createState() => FileReaderState();
}

/// The [FileReader]'s state
class FileReaderState extends State<FileReader> {
  late final PageController pageViewController;
  int? oldPage;
  bool isPagingEnabled = true;

  /// Manages the file viewer for a file.
  (Widget, bool, FileViewer) readFile(
      BuildContext context, FileThumbnail thumbnail, int fileIndex) {
    FileViewer viewer = thumbnail.placeholder.invokeData(
        widget.fileVault, thumbnail.file, thumbnail.name, thumbnail.data, this);
    if (oldPage == null && widget.initialThumbnail == fileIndex) {
      viewer.onFocus();
      oldPage = fileIndex;
    }
    pageViewController.addListener(() {
      if (!pageViewController.hasClients) return;

      if (pageViewController.page!.round() != oldPage &&
          pageViewController.page!.round() == fileIndex) {
        oldPage = fileIndex;
        viewer.onFocus();
      }
    });
    return (FutureBuilder(
        future: viewer.load(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return viewer.build(context);
          } else {
            return Center(
                child: Opacity(
                    opacity: 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Text(
                          viewer.loadingMessage(context),
                          textScaleFactor: 2.5,
                          textAlign: TextAlign.center,
                        )
                      ],
                    )));
          }
        }), viewer.extendBody(), viewer);
  }

  /// Build the [FileReader], this code is mostly made for loading times
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: isPagingEnabled
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          FileThumbnail currentThumbnail = widget.thumbnails()[index];
          var fileData = readFile(context, currentThumbnail, index);
          return Scaffold(
              appBar: AppBar(
                  title: Text(currentThumbnail.name),
                  leading: IconButton(
                          onPressed: () {
                            fileData.$3.dispose();
                            Navigator.pop(context);
                          },
                          icon:
                              const Icon(Icons.arrow_back))
                      ),
              body: fileData.$1,
              extendBodyBehindAppBar: fileData.$2,
              extendBody: fileData.$2);
        },
        itemCount: widget.thumbnails().length,
        scrollDirection: Axis.horizontal,
        controller: pageViewController,
        allowImplicitScrolling: true);
  }

  @override
  void initState() {
    pageViewController =
        PageController(initialPage: widget.initialThumbnail, keepPage: true);

    super.initState();
  }
}

/// The dialog to show when the user wants to rename an entity
class RenameWindow extends StatefulWidget {
  final void Function(String newName) onOkButtonPressed;
  final VoidCallback onCancelButtonPressed;
  final String initialName;

  const RenameWindow(
      {super.key,
      required this.onOkButtonPressed,
      required this.onCancelButtonPressed,
      required this.initialName});

  @override
  State<StatefulWidget> createState() => RenameWindowState();
}

/// The [RenameWindow]'s state
class RenameWindowState extends State<RenameWindow> {
  late final TextEditingController renameFieldController;
  bool hasNotChanged = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(S.of(context).rename),
        content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.none,
            controller: renameFieldController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              bool oldValue = hasNotChanged;
              hasNotChanged = value == widget.initialName;
              if (oldValue != hasNotChanged) {
                setState(() {});
              }
            }),
        actions: [
          TextButton(
              onPressed: widget.onCancelButtonPressed,
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: hasNotChanged
                  ? null
                  : () => widget.onOkButtonPressed(renameFieldController.text),
              child: Text(S.of(context).ok)),
        ]);
  }

  @override
  void initState() {
    renameFieldController = TextEditingController(text: widget.initialName);
    super.initState();
  }
}

/// The dialog to show when the user wants to create a new folder
class FolderCreationWindow extends StatefulWidget {
  final void Function(String newName) onCreateButtonPressed;
  final VoidCallback onCancelButtonPressed;
  final String initialName;

  const FolderCreationWindow(
      {super.key,
      required this.onCreateButtonPressed,
      required this.onCancelButtonPressed,
      required this.initialName});

  @override
  State<StatefulWidget> createState() => FolderCreationWindowState();
}

/// The [FolderCreationWindow]'s state
class FolderCreationWindowState extends State<FolderCreationWindow> {
  late final TextEditingController folderNameFieldController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(S.of(context).createANewFolder),
        content: TextField(
          autofocus: true,
          textInputAction: TextInputAction.none,
          controller: folderNameFieldController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: widget.onCancelButtonPressed,
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () =>
                  widget.onCreateButtonPressed(folderNameFieldController.text),
              child: Text(S.of(context).ok)),
        ]);
  }

  @override
  void initState() {
    folderNameFieldController = TextEditingController(text: widget.initialName);
    super.initState();
  }
}

/// One of the core UI elements of the app, this file explorer enables the user to see file thumbnails, their name and to play them, its state is [FileExplorerState]
class FileExplorer extends StatefulWidget {
  final Vault vault;
  final bool isEncryptedExportEnabled;

  const FileExplorer(this.vault, this.isEncryptedExportEnabled, {super.key});

  @override
  State<StatefulWidget> createState() => FileExplorerState();
}

/// The [FileExplorer]'s state
class FileExplorerState extends State<FileExplorer> {
  late List<FileThumbnail> thumbnails;
  bool keepThumbnailsLoaded = true;
  Future<void>? thumbnailCollector;
  double? thumbnailSize;
  late Map<String, dynamic> map;
  bool isSelectionMode = false;
  int amountOfFilesSelected = 0;
  int? loaderTarget;
  int? loaderCurrentLoad;
  static bool isPauseAllowed = false;
  static bool shouldNotificationBeSent = false;
  String currentLocalPath = '';
  static FileSortMethod currentSortMethod = FileSortMethod.name;
  final ScrollController gridViewController = ScrollController();

  static Future<void> exportEncryptedThumbnails(List<(String thumbnailFilePath, List<int> encryptionKey, Map<String, dynamic> data, List<int> fileContent, String unlockMechanismType, Map<String, dynamic> additionalUnlockData, String saveLocationPath)> message) async {
    for ((String thumbnailFilePath, List<int> encryptionKey, Map<String, dynamic> data, List<int> fileContent, String unlockMechanismType, Map<String, dynamic> additionalUnlockData, String saveLocationPath) data in message) {
      List<int> exportedFile =
      await FileExporter.exportFile(
          basename(data.$1),
          SecretKey(data.$2),
          data.$3,
          data.$4,
          data.$5,
          data.$6);
      File fileToSaveTo = File(join(data.$7,
          'Life_Chest_${md5RandomFileName()}.lcef'));
      fileToSaveTo.createSync();
      fileToSaveTo.writeAsBytesSync(exportedFile);
    }
  }

  /// A method to set and update the current sort method internally, not in the UI
  void setSortMethod(FileSortMethod newMethod) {
    currentSortMethod = newMethod;
    VaultsManager.saveVaults();
  }

  @override
  void initState() {
    super.initState();
    VaultsManager.loadVaults();
    isPauseAllowed = widget.vault.securityLevel >= 2;
    shouldNotificationBeSent = widget.vault.securityLevel == 1;
  }

  /// One of the worst part of my code, this build method essentially powers the full file explorer navigation system
  @override
  Widget build(BuildContext context) {
    thumbnailSize ??= MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? 4
            : 2);
    thumbnailCollector ??= reloadThumbnails();

    return WillPopScope(
      onWillPop: () async {
        if (currentLocalPath.isEmpty) {
          return true;
        } else {
          setState(() {
            gridViewController.jumpTo(0);
            if (!currentLocalPath.contains('/')) {
              currentLocalPath = '';
            } else {
              currentLocalPath = currentLocalPath.substring(
                  0, currentLocalPath.lastIndexOf('/'));
            }
            thumbnailCollector = reloadThumbnails();
          });
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                itemBuilder: (context) {
                  return [
                    if (kDebugMode)
                      PopupMenuItem(
                          onTap: () {
                            debugPrint(jsonEncode(map));
                          },
                          child: const Text('Print map')),
                    PopupMenuItem(
                        child: Text(S.of(context).sortBy),
                        onTap: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Wrap(children: [
                                    for (FileSortMethod method
                                        in FileSortMethod.values)
                                      ListTile(
                                          title: Text(
                                              method.getDisplayName(context)),
                                          onTap: () {
                                            setSortMethod(method);
                                            Navigator.of(context).pop();
                                            setState(() {
                                              thumbnailCollector =
                                                  reloadThumbnails();
                                            });
                                          })
                                  ]);
                                });
                          });
                        }),
                    PopupMenuItem(
                        onTap: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return FolderCreationWindow(
                                    onCreateButtonPressed: (newName) async {
                                      if (!newName.contains('/')) {
                                        map[md5RandomFileName()] = {
                                          'name':
                                              join(currentLocalPath, newName),
                                          'type': 'folder'
                                        };
                                      }
                                      File(join(widget.vault.path, '.map'))
                                          .writeAsBytesSync(
                                              (await VaultsManager.encryptMap(
                                                  widget.vault, map))!);
                                      isSelectionMode = false;
                                      setState(() {
                                        thumbnailCollector = reloadThumbnails();
                                      });
                                      if (context.mounted) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                    onCancelButtonPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    initialName: S.of(context).newFolder);
                              },
                            );
                          });
                        },
                        child: Text(S.of(context).createANewFolder)),
                    PopupMenuItem(
                        onTap: () {
                          setState(() {
                            isSelectionMode = true;
                            for (FileThumbnail thumbnail
                                in List.from(thumbnails)) {
                              if (!thumbnail.isSelected) {
                                thumbnails[thumbnails.indexOf(thumbnail)] =
                                    FileThumbnail(
                                        localPath: thumbnail.localPath,
                                        name: thumbnail.name,
                                        fullLocalPath: thumbnail.fullLocalPath,
                                        placeholder: thumbnail.placeholder,
                                        file: thumbnail.file,
                                        vault: thumbnail.vault,
                                        onPress: thumbnail.onPress,
                                        onLongPress: thumbnail.onLongPress,
                                        isSelected: true,
                                        data: thumbnail.data);
                              }
                            }
                            amountOfFilesSelected = thumbnails.length;
                          });
                        },
                        child: Text(S.of(context).selectAll)),
                    if (isSelectionMode) ...[
                      PopupMenuItem(
                          onTap: widget.isEncryptedExportEnabled ? () async {
                            List<FileThumbnail> filesToExport = [];

                            for (FileThumbnail thumbnail in thumbnails) {
                              if (thumbnail.isSelected) {
                                filesToExport.add(thumbnail);
                              }
                            }
                            String validDirectoryName =
                                S.of(context).lifeChestBulkSave;
                            Directory? downloadDirectory;
                            if (Platform.isIOS) {
                              downloadDirectory = await getDownloadsDirectory();

                              if (downloadDirectory == null) return;
                            } else {
                              downloadDirectory =
                                  Directory('/storage/emulated/0/Download');
                              // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                              if (!await downloadDirectory.exists()) {
                                downloadDirectory =
                                    await getExternalStorageDirectory();
                              }
                            }

                            Directory saveLocation = downloadDirectory!;

                            if (filesToExport.length > 1) {
                              String currentSuffix = '';
                              int currentDirID = 2;
                              List<FileSystemEntity> dirFiles =
                                  downloadDirectory.listSync();
                              while (dirFiles.any((element) =>
                                  basename(element.path) ==
                                  validDirectoryName + currentSuffix)) {
                                currentSuffix = ' ($currentDirID)';
                                currentDirID++;
                              }
                              validDirectoryName =
                                  validDirectoryName + currentSuffix;

                              saveLocation = Directory(
                                  join(saveLocation.path, validDirectoryName));
                              saveLocation.createSync();
                            }

                            List<int> encryptionKey = await widget.vault.encryptionKey!.extractBytes();

                            Isolate.spawn(exportEncryptedThumbnails, List<(String thumbnailFilePath, List<int> encryptionKey, Map<String, dynamic> data, List<int> fileContent, String unlockMechanismType, Map<String, dynamic> additionalUnlockData, String saveLocationPath)>.generate(filesToExport.length, (index) {
                              FileThumbnail fileToExport = filesToExport[index];

                              return (fileToExport.localPath, encryptionKey, fileToExport.data, fileToExport.file.readAsBytesSync(), widget.vault.unlockMechanismType, widget.vault.additionalUnlockData, saveLocation.path);
                            })).then((value) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(S.of(context).savedToFolder(
                                            basename(saveLocation.path)))));
                              }
                            });
                          } : null,
                          enabled: widget.isEncryptedExportEnabled,
                          child: Text(S.of(context).exportAsEncrypted)),
                      PopupMenuItem(
                          onTap: () async {
                            List<FileThumbnail> filesToExport = [];

                            for (FileThumbnail thumbnail in thumbnails) {
                              if (thumbnail.isSelected) {
                                filesToExport.add(thumbnail);
                              }
                            }
                            String validDirectoryName =
                                S.of(context).lifeChestBulkSave;
                            Directory? downloadDirectory;
                            if (Platform.isIOS) {
                              downloadDirectory = await getDownloadsDirectory();

                              if (downloadDirectory == null) return;
                            } else {
                              downloadDirectory =
                                  Directory('/storage/emulated/0/Download');
                              // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                              if (!await downloadDirectory.exists()) {
                                downloadDirectory =
                                    await getExternalStorageDirectory();
                              }
                            }

                            Directory saveLocation = downloadDirectory!;

                            if (filesToExport.length > 1) {
                              String currentSuffix = '';
                              int currentDirID = 2;
                              List<FileSystemEntity> dirFiles =
                                  downloadDirectory.listSync();
                              while (dirFiles.any((element) =>
                                  basename(element.path) ==
                                  validDirectoryName + currentSuffix)) {
                                currentSuffix = ' ($currentDirID)';
                                currentDirID++;
                              }
                              validDirectoryName =
                                  validDirectoryName + currentSuffix;

                              saveLocation = Directory(
                                  join(saveLocation.path, validDirectoryName));
                              saveLocation.createSync();
                            }

                            for (FileThumbnail thumbnail in filesToExport) {
                              Stream<List<int>> exportedFile =
                                  SingleThreadedRecovery
                                      .loadAndDecryptFile(widget.vault.encryptionKey!, thumbnail.file);

                              File fileToSaveTo =
                                  File(join(saveLocation.path, thumbnail.name));
                              fileToSaveTo.createSync();

                              fileToSaveTo.openWrite().addStream(exportedFile);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(S.of(context).savedToFolder(
                                          basename(saveLocation.path)))));
                            }
                          },
                          child: Text(S.of(context).exportAsCleartext)),
                      PopupMenuItem(
                          onTap: () async {
                            for (FileThumbnail thumbnail in thumbnails) {
                              if (thumbnail.isSelected) {
                                thumbnail.file.deleteSync();
                                map.remove(thumbnail.localPath);
                              }
                            }
                            List<int> encryptedMap =
                                (await VaultsManager.encryptMap(
                                    widget.vault, map))!;
                            setState(() {
                              // TODO: Forensic should be made to see if iOS/Android keeps any of the file data in storage, if yes fill the file with null bytes and then delete it.
                              File(join(widget.vault.path, '.map'))
                                  .writeAsBytesSync(encryptedMap);
                              isSelectionMode = false;
                              thumbnailCollector = reloadThumbnails();
                            });
                          },
                          child: Text(S.of(context).delete)),
                      if (amountOfFilesSelected == 1)
                        PopupMenuItem(
                            onTap: () {
                              FileThumbnail selectedThumbnail = thumbnails
                                  .firstWhere((element) => element.isSelected);
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return RenameWindow(
                                        onOkButtonPressed: (newName) async {
                                          map[selectedThumbnail.localPath]
                                              ['name'] = newName;
                                          File(join(widget.vault.path, '.map'))
                                              .writeAsBytesSync(
                                                  (await VaultsManager
                                                      .encryptMap(
                                                          widget.vault, map))!);
                                          isSelectionMode = false;
                                          thumbnailCollector =
                                              reloadThumbnails();
                                          if (context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        },
                                        onCancelButtonPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        initialName: selectedThumbnail.name);
                                  },
                                );
                              });
                            },
                            child: Text(S.of(context).rename))
                    ]
                  ];
                },
              )
            ],
            leading: IconButton(
                onPressed: () {
                  if (isSelectionMode) {
                    setState(() {
                      isSelectionMode = false;

                      for (FileThumbnail thumbnail in List.from(thumbnails)) {
                        if (thumbnail.isSelected) {
                          thumbnails[thumbnails.indexOf(thumbnail)] =
                              FileThumbnail(
                                  localPath: thumbnail.localPath,
                                  name: thumbnail.name,
                                  fullLocalPath: thumbnail.fullLocalPath,
                                  placeholder: thumbnail.placeholder,
                                  file: thumbnail.file,
                                  vault: thumbnail.vault,
                                  onPress: thumbnail.onPress,
                                  onLongPress: thumbnail.onLongPress,
                                  isSelected: false,
                                  data: thumbnail.data);
                        }
                      }
                    });
                  } else {
                    isPauseAllowed = false;
                    shouldNotificationBeSent = false;
                    if (currentLocalPath.isNotEmpty) {
                      if(gridViewController.positions.isNotEmpty) gridViewController.jumpTo(0);
                      setState(() {
                        if (!currentLocalPath.contains('/')) {
                          currentLocalPath = '';
                        } else {
                          currentLocalPath = currentLocalPath.substring(
                              0, currentLocalPath.lastIndexOf('/'));
                        }
                        thumbnailCollector = reloadThumbnails();
                      });
                    } else {
                      Navigator.pop(context);
                      widget.vault.encryptionKey!.destroy();
                    }
                  }
                },
                icon: isSelectionMode
                    ? const Icon(Icons.close)
                    : const Icon(Icons.arrow_back)),
            title: Text(isSelectionMode
                ? S.of(context).selected(amountOfFilesSelected)
                : (currentLocalPath.isNotEmpty
                    ? basenameWithoutExtension(currentLocalPath)
                    : widget.vault.name)),
            bottom: loaderTarget == null || loaderCurrentLoad == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(3),
                    child: LinearProgressIndicator(
                        value: loaderCurrentLoad! / loaderTarget!)),
            backgroundColor: isSelectionMode
                ? Theme.of(context).colorScheme.tertiary.withOpacity(.7)
                : null),
        floatingActionButton: GestureDetector(
          onLongPress: () {
            saveFolder(context);
          },
          child: FloatingActionButton(
              onPressed: () {
                saveFiles(context);
              },
              child: const Icon(Icons.add)),
        ),
        body: FutureBuilder(
          future: thumbnailCollector,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return thumbnails.isNotEmpty
                  ? GridView.count(
                      controller: gridViewController,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      crossAxisCount: MediaQuery.of(context).size.width >
                              MediaQuery.of(context).size.height
                          ? 4
                          : 2,
                      children: List.from(thumbnails))
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                            opacity: 0.45,
                            child: Text(
                              S.of(context).noFilesCreatedYet,
                              textScaleFactor: 2.5,
                              textAlign: TextAlign.center,
                            )),
                        FilledButton.tonal(
                            onPressed: () async {
                              saveFiles(context);
                            },
                            child: Text(S.of(context).addFiles))
                      ],
                    ));
            } else {
              return Center(
                  child: Opacity(
                      opacity: 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          Text(
                            S.of(context).loadingElements,
                            textScaleFactor: 2.5,
                            textAlign: TextAlign.center,
                          )
                        ],
                      )));
            }
          },
        ),
      ),
    );
  }

  /// Used to import files into the vault
  Future<void> saveFiles(BuildContext context) async {
    File mapFile = File(join(widget.vault.path, '.map'));
    mapFile.createSync(recursive: true);
    try {
      isPauseAllowed = false;
      shouldNotificationBeSent = false;
      List<File>? selectedFiles = await SingleThreadedRecovery.pickFilesToSave(
          dialogTitle: S.of(context).pickFilesDialogTitle);
      isPauseAllowed = widget.vault.securityLevel >= 2;
      shouldNotificationBeSent = widget.vault.securityLevel == 1;

      if (selectedFiles == null || selectedFiles.isEmpty) {
        return;
      }

      List<File> filesToDecrypt = [];
      List<File> filesToSave = [];

      for (File file in selectedFiles) {
        if (FileExporter.isExportedFile(await file.openRead(0, 32).last)) {
          filesToDecrypt.add(file);
        } else {
          filesToSave.add(file);
        }
      }

      setState(() {
        loaderTarget = filesToSave.length;
        loaderCurrentLoad = 0;
      });
      if (context.mounted && filesToDecrypt.isNotEmpty) {
        ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
            content:
                Text(S.of(context).detectedExportedFile(filesToDecrypt.length)),
            actions: [
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => FileUnlockWizard(
                                filesToDecrypt: filesToDecrypt)))
                        .then((value) {
                      if (value != null) saveFolder(context, value);
                    });
                  },
                  child: Text(S.of(context).useUnlockWizard)),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
                        reason: MaterialBannerClosedReason.dismiss);
                  },
                  child: Text(S.of(context).ignore))
            ]));
      }
      Map<String, Map<String, dynamic>> savedFiles = {};

      await for ((String, Map<String, dynamic>) savedFile
          in SingleThreadedRecovery.progressivelySaveFiles(
              widget.vault.encryptionKey!, widget.vault.path, currentLocalPath,
              filesToSave: filesToSave)) {
        savedFiles[savedFile.$1] = savedFile.$2;
        setState(() {
          loaderCurrentLoad = loaderCurrentLoad! + 1;
        });
      }

      setState(() {
        loaderTarget = null;
        loaderCurrentLoad = null;
      });
      map = VaultsManager.constructMap(widget.vault,
          oldMap: map, additionalFiles: savedFiles);
      mapFile.writeAsBytesSync(
          (await VaultsManager.encryptMap(widget.vault, map))!);

      setState(() {
        thumbnailCollector = reloadThumbnails();
      });
    } on PlatformException {
      return;
    }
  }

  /// Used to import a folder into the vault
  Future<void> saveFolder(BuildContext context,
      [List<(Map<String, dynamic> metadata, List<int> data)>?
          importedFilesToSave]) async {
    File mapFile = File(join(widget.vault.path, '.map'));
    mapFile.createSync(recursive: true);
    List<File>? filesToSave;
    String? rootFolderPath;
    try {
      if (importedFilesToSave == null) {
        isPauseAllowed = false;
        shouldNotificationBeSent = false;
        Directory? pickedFolder =
            (await SingleThreadedRecovery.pickFolderToSave(
                dialogTitle: S.of(context).pickFolderDialogTitle));
        if (pickedFolder == null) {
          return;
        }
        rootFolderPath = pickedFolder.path;
        List<File> selectedFiles = [];
        for (FileSystemEntity entity
            in pickedFolder.listSync(recursive: true)) {
          if (entity is File) {
            selectedFiles.add(entity);
          } else {
            map[md5RandomFileName()] = {
              'name': join(currentLocalPath,
                  relative(entity.path, from: pickedFolder.path)),
              'type': 'folder'
            };
          }
        }

        List<File> filesToDecrypt = [];
        List<File> filesToSave = [];

        for (File file in selectedFiles) {
          if (FileExporter.isExportedFile(await file.openRead(0, 32).last)) {
            filesToDecrypt.add(file);
          } else {
            selectedFiles.add(file);
          }
        }

        isPauseAllowed = widget.vault.securityLevel >= 2;
        shouldNotificationBeSent = widget.vault.securityLevel == 1;

        setState(() {
          loaderTarget = filesToSave.length;
          loaderCurrentLoad = 0;
        });

        if (context.mounted && filesToDecrypt.isNotEmpty) {
          ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
              content: Text(
                  S.of(context).detectedExportedFile(filesToDecrypt.length)),
              actions: [
                TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .removeCurrentMaterialBanner();
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => FileUnlockWizard(
                                  filesToDecrypt: filesToDecrypt)))
                          .then((value) {
                        if (value != null) saveFolder(context, value);
                      });
                    },
                    child: Text(S.of(context).useUnlockWizard)),
                TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
                          reason: MaterialBannerClosedReason.dismiss);
                    },
                    child: Text(S.of(context).ignore))
              ]));
        }
      } else {
        setState(() {
          loaderTarget = importedFilesToSave.length;
          loaderCurrentLoad = 0;
        });
      }

      Map<String, Map<String, dynamic>> savedFiles = {};

      await for ((String, Map<String, dynamic>) savedFile
          in SingleThreadedRecovery.progressivelySaveFiles(
              widget.vault.encryptionKey!, widget.vault.path, currentLocalPath,
              filesToSave: filesToSave,
              rootFolderPath: rootFolderPath,
              importedFilesToSave: importedFilesToSave)) {
        savedFiles[savedFile.$1] = savedFile.$2;
        setState(() {
          loaderCurrentLoad = loaderCurrentLoad! + 1;
        });
      }

      setState(() {
        loaderTarget = null;
        loaderCurrentLoad = null;
      });
      map = VaultsManager.constructMap(widget.vault,
          oldMap: map, additionalFiles: savedFiles);
      mapFile.writeAsBytesSync(
          (await VaultsManager.encryptMap(widget.vault, map))!);

      setState(() {
        thumbnailCollector = reloadThumbnails();
      });
    } on PlatformException {
      return;
    }
  }

  /// A helper method to know if an entity is 1 level deeper in the tree than a local path so that whe can know if the UI should draw it
  static bool shouldThumbnailBeShown(
      String fileLocalPath, String currentLocalPath) {
    return (currentLocalPath.isEmpty && !fileLocalPath.contains('/')) ||
        (fileLocalPath.startsWith(currentLocalPath) &&
            fileLocalPath.split('/').length -
                    (currentLocalPath.isEmpty ? 0 : 1) ==
                currentLocalPath.split('/').length);
  }

  /// Implementation of the sorting system internally, not directly in the UI, this method sorts the entire Vault map
  static Map<String, dynamic> sortMap(
      FileSortMethod currentMethod, Map<String, dynamic> currentMap) {
    List<MapEntry<String, dynamic>> sortableMap = List.from(currentMap.entries);

    sortableMap.sort((a, b) {
      return currentMethod.sort(
          basename(a.value['name']), basename(b.value['name']));
    });

    Map<String, dynamic> sortedMap = Map.fromEntries(sortableMap);

    return sortedMap;
  }

  /// Updates the thumbnails internally, not in the UI
  Future<bool> reloadThumbnails() async {
    File mapFile = File(join(widget.vault.path, '.map'));
    if (!mapFile.existsSync()) {
      return false;
    }

    map = (await VaultsManager.decryptMap(
        widget.vault, mapFile.readAsBytesSync()))!;
    List<FileThumbnail> createdThumbnails = [];

    keepThumbnailsLoaded = map.length <= 20;

    Map<String, FileThumbnailsPlaceholder> fileTypes =
        FileThumbnailsPlaceholder.getPlaceholderFromFileName(
            List.from(map.values));
    Map<String, dynamic> sortedMap = sortMap(currentSortMethod, map);
    assert(sortedMap.length == map.length);
    for (MapEntry<String, dynamic> mappedFile in sortedMap.entries) {
      if (shouldThumbnailBeShown(mappedFile.value['name'], currentLocalPath)) {
        ValueKey<String> thumbnailKey = ValueKey(mappedFile.key);
        createdThumbnails.add(FileThumbnail(
            key: thumbnailKey,
            localPath: mappedFile.key,
            name: basename(mappedFile.value['name']),
            fullLocalPath: mappedFile.value['name'],
            placeholder: fileTypes[mappedFile.value['name']]!,
            file: File(join(widget.vault.path, mappedFile.key)),
            vault: widget.vault,
            onPress: thumbnailTap,
            onLongPress: thumbnailLongTap,
            isSelected: false,
            data: mappedFile.value));
      }
    }

    thumbnails = createdThumbnails;

    return true;
  }

  /// Too keep the thumbnails updated in the [FileReader]
  List<FileThumbnail> _getThumbnails() {
    return thumbnails;
  }

  /// The callback used when the user clicks on a thumbnail
  void thumbnailTap(BuildContext context, FileThumbnail thumbnail) {
    if (!isSelectionMode) {
      if (thumbnail.placeholder == FileThumbnailsPlaceholder.folder) {
        gridViewController.jumpTo(0);
        currentLocalPath = thumbnail.fullLocalPath;
        setState(() {
          thumbnailCollector = reloadThumbnails();
        });
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FileReader(
                    thumbnails: _getThumbnails,
                    fileVault: widget.vault,
                    initialThumbnail: thumbnails.indexOf(thumbnail))));
      }

      return;
    }
    setState(() {
      thumbnails[thumbnails.indexOf(thumbnail)] = FileThumbnail(
          localPath: thumbnail.localPath,
          name: thumbnail.name,
          fullLocalPath: thumbnail.fullLocalPath,
          placeholder: thumbnail.placeholder,
          file: thumbnail.file,
          vault: thumbnail.vault,
          onPress: thumbnail.onPress,
          onLongPress: thumbnail.onLongPress,
          isSelected: !thumbnail.isSelected,
          data: thumbnail.data);
      if (!thumbnail.isSelected) {
        amountOfFilesSelected++;
      } else {
        amountOfFilesSelected--;
        if (amountOfFilesSelected == 0) {
          isSelectionMode = false;
        }
      }
    });

    return;
  }

  /// The callback used when the user uses a long tap on a thumbnail
  void thumbnailLongTap(FileThumbnail thumbnail) {
    setState(() {
      if (!isSelectionMode) {
        isSelectionMode = true;
        amountOfFilesSelected = 1;
      } else if (!thumbnail.isSelected) {
        amountOfFilesSelected++;
      }
      thumbnails[thumbnails.indexOf(thumbnail)] = FileThumbnail(
          localPath: thumbnail.localPath,
          name: thumbnail.name,
          fullLocalPath: thumbnail.fullLocalPath,
          placeholder: thumbnail.placeholder,
          file: thumbnail.file,
          vault: thumbnail.vault,
          onPress: thumbnail.onPress,
          onLongPress: thumbnail.onLongPress,
          isSelected: true,
          data: thumbnail.data);
    });
  }
}
