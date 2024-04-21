import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/file_explorer/explorer_data.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:life_chest/file_explorer/file_sort_methods.dart';
import 'package:life_chest/file_explorer/file_thumbnail.dart';
import 'package:life_chest/file_explorer/file_unlock_wizard.dart';
import 'package:life_chest/file_recovery/file_exporter.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/new_chest.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef FileExportArgs = ({
  String thumbnailFilePath,
  List<int> encryptionKey,
  ThumbnailData data,
  File encryptedFile,
  String unlockMechanismType,
  Map<String, dynamic> additionalUnlockData,
  Uint8List nonce
});

/// The file reader, this enable the user to see file and to browse between them while keeping a cache of them
class FileReader extends StatefulWidget {
  final int initialThumbnail;

  const FileReader(this.initialThumbnail, {super.key});

  @override
  State<StatefulWidget> createState() => FileReaderState();
}

/// The [FileReader]'s state
class FileReaderState extends State<FileReader> {
  late PageController pageViewController;
  int? oldPage;
  bool isPagingEnabled = true;
  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;
  set isFullscreen(bool newValue) {
    if (newValue == _isFullscreen) return;

    if (newValue) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _isFullscreen = newValue;

    update();
  }

  /// Manages the file viewer for a file.
  (Widget, bool, FileViewer) readFile(
      BuildContext context, ThumbnailData thumbnail, int fileIndex) {
    var fileVault = ExplorerData.of(context).state.vault;

    FileViewer viewer = thumbnail.placeholder.invokeData(fileVault,
        thumbnail.getFile(fileVault), thumbnail.name, thumbnail.data, this);
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
    return (
      viewer.loaded
          ? viewer.build(context)
          : FutureBuilder(
              future: viewer.load(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
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
                                textScaler: const TextScaler.linear(2.5),
                                textAlign: TextAlign.center,
                              )
                            ],
                          )));
                }
              }),
      viewer.extendBody(),
      viewer
    );
  }

  Map<int, (Widget, bool, FileViewer)> files = {};

  /// Build the [FileReader], this code is mostly made for loading times
  @override
  Widget build(BuildContext context) {
    var thumbnails = ExplorerData.of(context).state.thumbnails!;

    return isPagingEnabled
        ? PageView.builder(
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              ThumbnailData currentThumbnail = thumbnails[index];
              files[index] ??= readFile(context, currentThumbnail, index);

              return StatefulBuilder(builder: (context, setState) {
                return buildPage(currentThumbnail, index, context);
              });
            },
            itemCount: thumbnails.length,
            scrollDirection: Axis.horizontal,
            controller: pageViewController,
            allowImplicitScrolling: true)
        : buildPage(thumbnails[pageViewController.page!.toInt()],
            pageViewController.page!.toInt(), context);
  }

  Scaffold buildPage(
      ThumbnailData currentThumbnail, int index, BuildContext context) {
    return Scaffold(
        backgroundColor: isFullscreen ? Colors.transparent : null,
        appBar: isFullscreen
            ? null
            : AppBar(
                title: Text(currentThumbnail.name),
                leading: IconButton(
                    onPressed: () {
                      files[index]!.$3.dispose();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back))),
        body: files[index]!.$1,
        extendBodyBehindAppBar: files[index]!.$2,
        extendBody: files[index]!.$2);
  }

  @override
  void initState() {
    pageViewController =
        PageController(initialPage: widget.initialThumbnail, keepPage: true);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void update() {
    setState(() {});
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

/// The dialog to show when the user wants to rename an entity
class ChangeBehaviorWindow extends StatefulWidget {
  final void Function(int newSecurityLevel) onOkButtonPressed;
  final VoidCallback onCancelButtonPressed;
  final int initialSecurityLevel;

  const ChangeBehaviorWindow(
      {super.key,
      required this.onOkButtonPressed,
      required this.onCancelButtonPressed,
      required this.initialSecurityLevel});

  @override
  State<StatefulWidget> createState() => ChangeBehaviorWindowState();
}

/// The [RenameWindow]'s state
class ChangeBehaviorWindowState extends State<ChangeBehaviorWindow> {
  late final TextEditingController renameFieldController;
  bool hasNotChanged = true;
  late int currentIndex;

  @override
  Widget build(BuildContext context) {
    var possibilities = CreateNewChestPageState.onPausePossibilities(context);

    return AlertDialog(
        title: Text(S.of(context).changeBehavior),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).changeBehaviorSubtitle),
            ListTile(
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(spacing: 5.0, clipBehavior: Clip.none, children: [
                  ...List<Widget>.generate(3, (index) {
                    return ChoiceChip(
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        label: Text(possibilities[index].$1),
                        selected: currentIndex == possibilities[index].$2,
                        onSelected: (value) {
                          setState(() {
                            currentIndex = possibilities[index].$2;
                            hasNotChanged =
                                currentIndex == widget.initialSecurityLevel;
                          });
                        });
                  })
                ]),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: widget.onCancelButtonPressed,
              child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: hasNotChanged
                  ? null
                  : () => widget.onOkButtonPressed(currentIndex),
              child: Text(S.of(context).ok)),
        ]);
  }

  @override
  void initState() {
    currentIndex = widget.initialSecurityLevel;
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
  late ExplorerState state;

  Future<void>? thumbnailCollector;
  late Map<String, dynamic> map;
  bool get isSelectionMode => state.selectedThumbnails?.isNotEmpty ?? false;
  int get amountOfFilesSelected => state.selectedThumbnails?.length ?? 0;
  int? loaderTarget;
  int? loaderCurrentLoad;
  static bool isPauseAllowed = false;
  static bool shouldNotificationBeSent = false;
  String _currentLocalPath = '';
  String get currentLocalPath => _currentLocalPath;
  set currentLocalPath(String newPath) {
    _currentLocalPath = newPath;
    if (newPath.isNotEmpty) {
      canPop = false;
    }
  }

  static FileSortMethod currentSortMethod = FileSortMethod.name;
  final ScrollController viewController = ScrollController();

  bool canPop = true;

  static Future<void> exportEncryptedThumbnails(
      (SendPort, List<FileExportArgs>) message) async {
    for (FileExportArgs data in message.$2) {
      var target = data.encryptedFile.openWrite();
      await FileExporter.exportFile(
          basename(data.thumbnailFilePath),
          SecretKey(data.encryptionKey),
          data.data,
          data.encryptedFile.openRead(),
          data.encryptedFile.path,
          data.unlockMechanismType,
          data.additionalUnlockData,
          target,
          data.nonce);
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

    state = (
      onThumbnailTap: thumbnailTap,
      onThumbnailLongTap: thumbnailLongTap,
      vault: widget.vault,
      isGridView: false,
      selectedThumbnails: null,
      thumbnails: null,
      thumbnailSize: null
    );

    thumbnailCollector = reloadThumbnails();
  }

  /// One of the worst part of my code, this build method essentially powers the full file explorer navigation system
  @override
  Widget build(BuildContext context) {
    if (state.thumbnailSize == null) {
      state = state.copyWith(
          thumbnailSize: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? 4
                  : 2));
    }

    thumbnailCollector ??= reloadThumbnails();

    return ExplorerData(
      state: state,
      child: PopScope(
        canPop: canPop,
        onPopInvoked: (didPop) {
          setState(() {
            if (!viewController.hasClients) return;

            viewController.jumpTo(0);
            if (!currentLocalPath.contains('/')) {
              currentLocalPath = '';
            } else {
              currentLocalPath = currentLocalPath.substring(
                  0, currentLocalPath.lastIndexOf('/'));
            }
            thumbnailCollector = reloadThumbnails();
          });
        },
        child: Scaffold(
          appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () => setState(() {
                          state = state.copyWith(isGridView: !state.isGridView);
                        }),
                    icon: Icon(state.isGridView
                        ? Icons.view_list_outlined
                        : Icons.grid_view_outlined)),
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
                                        state = state.copyWith(
                                            selectedThumbnails: {},
                                            thumbnails: []);
                                        setState(() {
                                          thumbnailCollector =
                                              reloadThumbnails();
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
                            if (state.thumbnails == null) return;

                            setState(() {
                              state = state.copyWith(
                                  selectedThumbnails: state.thumbnails!
                                      .map(
                                        (e) => e.localPath,
                                      )
                                      .toSet());
                            });
                          },
                          child: Text(S.of(context).selectAll)),
                      if (isSelectionMode) ...[
                        PopupMenuItem(
                            onTap: widget.isEncryptedExportEnabled
                                ? () async {
                                    if (state.thumbnails == null) return;

                                    List<ThumbnailData> filesToExport = state
                                        .thumbnails!
                                        .where((element) => state
                                            .selectedThumbnails!
                                            .contains(element.localPath))
                                        .toList();

                                    setState(() {
                                      loaderTarget = filesToExport.length;
                                      loaderCurrentLoad = 0;
                                    });

                                    Directory directory =
                                        await getDownloadsDirectory() ??
                                            (await getExternalStorageDirectory())!;

                                    Directory outDir = Directory(join(
                                        directory.path,
                                        'LifeChest-export-${DateTime.now().millisecondsSinceEpoch}'))
                                      ..createSync();

                                    for (var fileToExport in filesToExport) {
                                      File targetFile = File(join(
                                          outDir.path,
                                          setExtension(
                                              basenameWithoutExtension(
                                                  fileToExport.fullLocalPath),
                                              '.lcef')));

                                      await FileExporter.exportFile(
                                          basename(fileToExport.localPath),
                                          widget.vault.encryptionKey!,
                                          fileToExport,
                                          fileToExport
                                              .getFile(widget.vault)
                                              .openRead(),
                                          fileToExport
                                              .getFile(widget.vault)
                                              .path,
                                          widget.vault.unlockMechanismType,
                                          widget.vault.additionalUnlockData,
                                          targetFile.openWrite(),
                                          await SingleThreadedRecovery
                                              .findNonce(fileToExport
                                                  .getFile(widget.vault)
                                                  .path));

                                      setState(() {
                                        loaderCurrentLoad =
                                            loaderCurrentLoad! + 1;
                                      });
                                    }

                                    setState(() {
                                      loaderTarget = null;
                                      loaderCurrentLoad = null;
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  S
                                                      .of(context)
                                                      .savedToFolderWarning,
                                                  style: const TextStyle(
                                                      color: Colors.amber))));
                                    }
                                  }
                                : null,
                            enabled: widget.isEncryptedExportEnabled,
                            child: Text(S.of(context).exportAsEncrypted)),
                        PopupMenuItem(
                            onTap: () async {
                              if (state.thumbnails == null) return;

                              List<ThumbnailData> filesToExport = state
                                  .thumbnails!
                                  .where((element) => state.selectedThumbnails!
                                      .contains(element.localPath))
                                  .toList();

                              String validDirectoryName =
                                  S.of(context).lifeChestBulkSave;
                              Directory? downloadDirectory;
                              if (Platform.isIOS) {
                                downloadDirectory =
                                    await getDownloadsDirectory();

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

                                saveLocation = Directory(join(
                                    saveLocation.path, validDirectoryName));
                                saveLocation.createSync();
                              }

                              for (var thumbnail in filesToExport) {
                                Stream<List<int>> exportedFile =
                                    await SingleThreadedRecovery
                                        .loadAndDecryptFile(
                                            widget.vault.encryptionKey!,
                                            File(join(widget.vault.path,
                                                thumbnail.localPath)),
                                            Mac(thumbnail.data['mac']));

                                File fileToSaveTo = File(
                                    join(saveLocation.path, thumbnail.name));
                                fileToSaveTo.createSync();

                                fileToSaveTo
                                    .openWrite()
                                    .addStream(exportedFile);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(S.of(context).savedToFolder)));
                              }
                            },
                            child: Text(S.of(context).exportAsCleartext)),
                        PopupMenuItem(
                            onTap: () async {
                              if (state.thumbnails == null) return;

                              List<ThumbnailData> filesToDelete = state
                                  .thumbnails!
                                  .where((element) => state.selectedThumbnails!
                                      .contains(element.key))
                                  .toList();

                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                            title: Text(S
                                                .of(context)
                                                .areYouSureDeleteFiles(
                                                    filesToDelete.length)),
                                            content: Text(S
                                                .of(context)
                                                .lostDataContBeRecovered),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child:
                                                      Text(S.of(context).no)),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child:
                                                      Text(S.of(context).yes))
                                            ])).then((value) async {
                                  if (value == true) {
                                    for (var thumbnail in filesToDelete) {
                                      if (thumbnail
                                          .getFile(state.vault)
                                          .existsSync()) {
                                        thumbnail
                                            .getFile(state.vault)
                                            .deleteSync();
                                      }

                                      if (thumbnail.data['type'] == 'folder') {
                                        for (ThumbnailData innerRawThumbnail
                                            in List.from(map.entries)) {
                                          if (isWithin(
                                              thumbnail.fullLocalPath,
                                              innerRawThumbnail
                                                  .fullLocalPath)) {
                                            File innerRawThumbnailFile = File(
                                                join(
                                                    widget.vault.path,
                                                    innerRawThumbnail
                                                        .localPath));
                                            if (innerRawThumbnailFile
                                                .existsSync()) {
                                              innerRawThumbnailFile
                                                  .deleteSync();
                                            }
                                            map.remove(
                                                innerRawThumbnail.localPath);
                                          }
                                        }
                                      }
                                      map.remove(thumbnail.localPath);
                                    }
                                    List<int> encryptedMap =
                                        (await VaultsManager.encryptMap(
                                            widget.vault, map))!;
                                    setState(() {
                                      File(join(widget.vault.path, '.map'))
                                          .writeAsBytesSync(encryptedMap);
                                      state = state.copyWith(
                                          selectedThumbnails: {},
                                          thumbnails: []);
                                      thumbnailCollector = reloadThumbnails();
                                    });
                                  }
                                });
                              });
                            },
                            child: Text(S.of(context).delete)),
                        if (amountOfFilesSelected == 1)
                          PopupMenuItem(
                              onTap: () {
                                ThumbnailData selectedThumbnail =
                                    state.thumbnails!.firstWhere((element) =>
                                        element.localPath ==
                                        state.selectedThumbnails!.single);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return RenameWindow(
                                          onOkButtonPressed: (newName) async {
                                            map[selectedThumbnail.localPath]
                                                ['name'] = newName;
                                            File(join(
                                                    widget.vault.path, '.map'))
                                                .writeAsBytesSync(
                                                    (await VaultsManager
                                                        .encryptMap(
                                                            widget.vault,
                                                            map))!);
                                            state = state.copyWith(
                                                selectedThumbnails: {},
                                                thumbnails: []);

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
                        state = state.copyWith(selectedThumbnails: {});
                      });
                    } else {
                      isPauseAllowed = false;
                      shouldNotificationBeSent = false;
                      if (currentLocalPath.isNotEmpty) {
                        if (viewController.positions.isNotEmpty) {
                          viewController.jumpTo(0);
                        }
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
                  ? Theme.of(context).colorScheme.primaryContainer
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
              if (snapshot.connectionState == ConnectionState.done) {
                return state.thumbnails!.isNotEmpty
                    ? (state.isGridView
                        ? GridView.builder(
                            controller: viewController,
                            itemBuilder: (context, index) {
                              return FileThumbnail(state.thumbnails![index]);
                            },
                            itemCount: state.thumbnails!.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                          )
                        : ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              ThumbnailData data = state.thumbnails![index];

                              return FileThumbnail(data);
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            controller: viewController,
                            itemCount: state.thumbnails!.length,
                          ))
                    : Center(
                        child: Text(
                        S.of(context).noFilesCreatedYet,
                        textScaler: const TextScaler.linear(2.5),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
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
                              textScaler: const TextScaler.linear(2.5),
                              textAlign: TextAlign.center,
                            )
                          ],
                        )));
              }
            },
          ),
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
  static List<MapEntry<String, dynamic>> sortMap(
      FileSortMethod currentMethod, Map<String, dynamic> currentMap) {
    List<MapEntry<String, dynamic>> sortableMap = List.from(currentMap.entries);

    return currentMethod.sort(sortableMap);
  }

  /// Updates the thumbnails internally, not in the UI
  Future<void> reloadThumbnails() async {
    File mapFile = File(join(widget.vault.path, '.map'));
    if (!mapFile.existsSync()) {
      return;
    }

    map = (await VaultsManager.decryptMap(
        widget.vault, mapFile.readAsBytesSync()))!;

    map.removeWhere((key, value) =>
        !shouldThumbnailBeShown(value['name'], currentLocalPath));

    var sortedMap = sortMap(currentSortMethod, map);

    assert(sortedMap.length == map.length);

    state = state.copyWith(thumbnails: sortedMap, selectedThumbnails: {});

    return;
  }

  /// The callback used when the user clicks on a thumbnail
  void thumbnailTap(BuildContext context, FileThumbnail thumbnail) {
    if (!isSelectionMode) {
      if (thumbnail.data.placeholder == FileThumbnailsPlaceholder.folder) {
        viewController.jumpTo(0);
        currentLocalPath = thumbnail.data.fullLocalPath;
        setState(() {
          state = state.copyWith(selectedThumbnails: {}, thumbnails: null);
          thumbnailCollector = reloadThumbnails();
        });
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExplorerData(
                    state: state,
                    child: FileReader(
                        state.thumbnails!.indexOf(thumbnail.data)))));
      }

      return;
    } else {
      setState(() {
        if (state.isSelected(thumbnail.data.localPath)) {
          state = state.copyWith(
              selectedThumbnails: state.selectedThumbnails!
                ..remove(thumbnail.data.localPath));
        } else {
          state = state.copyWith(
              selectedThumbnails: state.selectedThumbnails!
                ..add(thumbnail.data.localPath));
        }
      });
    }

    return;
  }

  /// The callback used when the user uses a long tap on a thumbnail
  void thumbnailLongTap(FileThumbnail thumbnail) {
    setState(() {
      if (!isSelectionMode) {
        state = state.copyWith(selectedThumbnails: {thumbnail.data.localPath});
      } else if (!state.isSelected(thumbnail.data.localPath)) {
        state = state.copyWith(selectedThumbnails: {
          ...state.selectedThumbnails!,
          thumbnail.data.localPath
        });
      }
    });
  }
}
