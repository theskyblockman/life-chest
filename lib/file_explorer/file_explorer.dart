import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:life_chest/file_explorer/file_sort_methods.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_explorer/file_thumbnail.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';

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

class FileReaderState extends State<FileReader> {
  late final PageController pageViewController;
  int? oldPage;

  Widget readFile(
      BuildContext context, FileThumbnail thumbnail, int fileIndex) {
    FileViewer viewer = thumbnail.placeholder.invokeData(
        widget.fileVault, thumbnail.file, thumbnail.name, thumbnail.data);
    if (oldPage == null) {
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
    return FutureBuilder(
        future: viewer.load(),
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemBuilder: (context, index) {
          FileThumbnail currentThumbnail = widget.thumbnails()[index];
          return Scaffold(
              appBar: AppBar(
                  title: Text(currentThumbnail.name,
                      style: currentThumbnail.placeholder !=
                              FileThumbnailsPlaceholder.audio
                          ? const TextStyle(color: Colors.white)
                          : null),
                  backgroundColor: Colors.transparent,
                  leading: currentThumbnail.placeholder !=
                          FileThumbnailsPlaceholder.audio
                      ? IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white))
                      : null),
              body: readFile(context, currentThumbnail, index),
              backgroundColor: currentThumbnail.placeholder ==
                      FileThumbnailsPlaceholder.audio
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.black,
              extendBodyBehindAppBar: true,
              extendBody: true);
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

class RenameWindowState extends State<RenameWindow> {
  late final TextEditingController renameFieldController;
  bool hasNotChanged = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.rename),
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
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: hasNotChanged
                  ? null
                  : () => widget.onOkButtonPressed(renameFieldController.text),
              child: Text(AppLocalizations.of(context)!.ok)),
        ]);
  }

  @override
  void initState() {
    renameFieldController = TextEditingController(text: widget.initialName);
    super.initState();
  }
}

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

class FolderCreationWindowState extends State<FolderCreationWindow> {
  late final TextEditingController folderNameFieldController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.createANewFolder),
        content: TextField(
          autofocus: true,
          textInputAction: TextInputAction.none,
          controller: folderNameFieldController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: widget.onCancelButtonPressed,
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () =>
                  widget.onCreateButtonPressed(folderNameFieldController.text),
              child: Text(AppLocalizations.of(context)!.ok)),
        ]);
  }

  @override
  void initState() {
    folderNameFieldController = TextEditingController(text: widget.initialName);
    super.initState();
  }
}

class FileExplorer extends StatefulWidget {
  final Vault vault;

  const FileExplorer(this.vault, {super.key});

  @override
  State<StatefulWidget> createState() => FileExplorerState();
}

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
                        child: Text(AppLocalizations.of(context)!.sortBy),
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
                                    initialName: AppLocalizations.of(context)!
                                        .newFolder);
                              },
                            );
                          });
                        },
                        child: Text(
                            AppLocalizations.of(context)!.createANewFolder)),
                    if (isSelectionMode) ...[
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
                          child: Text(AppLocalizations.of(context)!.delete)),
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
                            child: Text(AppLocalizations.of(context)!.rename)),
                      PopupMenuItem(
                          onTap: () {
                            setState(() {
                              for (FileThumbnail thumbnail
                                  in List.from(thumbnails)) {
                                if (!thumbnail.isSelected) {
                                  thumbnails[thumbnails.indexOf(thumbnail)] =
                                      FileThumbnail(
                                          localPath: thumbnail.localPath,
                                          name: thumbnail.name,
                                          fullLocalPath:
                                              thumbnail.fullLocalPath,
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
                          child: Text(AppLocalizations.of(context)!.selectAll))
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
                    }
                  }
                },
                icon: isSelectionMode
                    ? const Icon(Icons.close)
                    : const Icon(Icons.arrow_back)),
            title: Text(isSelectionMode
                ? AppLocalizations.of(context)!.selected(amountOfFilesSelected)
                : widget.vault.name +
                    (currentLocalPath.isNotEmpty ? '/$currentLocalPath' : '')),
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
          child: FloatingActionButton.large(
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
                              AppLocalizations.of(context)!.noFilesCreatedYet,
                              textScaleFactor: 2.5,
                              textAlign: TextAlign.center,
                            )),
                        FilledButton.tonal(
                            onPressed: () async {
                              saveFiles(context);
                            },
                            child: Text(AppLocalizations.of(context)!.addFiles))
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
                            AppLocalizations.of(context)!.loadingElements,
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

  Future<void> saveFiles(BuildContext context) async {
    File mapFile = File(join(widget.vault.path, '.map'));
    mapFile.createSync(recursive: true);
    try {
      isPauseAllowed = false;
      shouldNotificationBeSent = false;
      List<File>? selectedFiles = await SingleThreadedRecovery.pickFilesToSave(
          dialogTitle: AppLocalizations.of(context)!.pickFilesDialogTitle);
      isPauseAllowed = widget.vault.securityLevel >= 2;
      shouldNotificationBeSent = widget.vault.securityLevel == 1;

      if (selectedFiles == null || selectedFiles.isEmpty) {
        return;
      }
      setState(() {
        loaderTarget = selectedFiles.length;
        loaderCurrentLoad = 0;
      });

      Map<String, Map<String, dynamic>> savedFiles = {};

      await for (MapEntry<String, Map<String, dynamic>> savedFile
          in SingleThreadedRecovery.progressivelySaveFiles(
              widget.vault.encryptionKey!, widget.vault.path, currentLocalPath,
              filesToSave: selectedFiles)) {
        savedFiles[savedFile.key] = savedFile.value;
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

  Future<void> saveFolder(BuildContext context) async {
    File mapFile = File(join(widget.vault.path, '.map'));
    mapFile.createSync(recursive: true);
    try {
      isPauseAllowed = false;
      shouldNotificationBeSent = false;
      Directory? pickedFolder = (await SingleThreadedRecovery.pickFolderToSave(
          dialogTitle: AppLocalizations.of(context)!.pickFolderDialogTitle));
      if (pickedFolder == null) {
        return;
      }
      List<File> filesToSave = [];
      for (FileSystemEntity entity in pickedFolder.listSync(recursive: true)) {
        if (entity is File) {
          filesToSave.add(entity);
        } else {
          map[md5RandomFileName()] = {
            'name': join(currentLocalPath,
                relative(entity.path, from: pickedFolder.path)),
            'type': 'folder'
          };
        }
      }
      isPauseAllowed = widget.vault.securityLevel >= 2;
      shouldNotificationBeSent = widget.vault.securityLevel == 1;

      setState(() {
        loaderTarget = filesToSave.length;
        loaderCurrentLoad = 0;
      });

      Map<String, Map<String, dynamic>> savedFiles = {};

      await for (MapEntry<String, Map<String, dynamic>> savedFile
          in SingleThreadedRecovery.progressivelySaveFiles(
              widget.vault.encryptionKey!, widget.vault.path, currentLocalPath,
              filesToSave: filesToSave, rootFolderPath: pickedFolder.path)) {
        savedFiles[savedFile.key] = savedFile.value;
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

  static bool shouldThumbnailBeShown(
      String fileLocalPath, String currentLocalPath) {
    return (currentLocalPath.isEmpty && !fileLocalPath.contains('/')) ||
        (fileLocalPath.startsWith(currentLocalPath) &&
            fileLocalPath.split('/').length -
                    (currentLocalPath.isEmpty ? 0 : 1) ==
                currentLocalPath.split('/').length);
  }

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

  List<FileThumbnail> _getThumbnails() {
    return thumbnails;
  }

  void thumbnailTap(BuildContext context, FileThumbnail thumbnail) {
    debugPrint(currentLocalPath);
    if (!isSelectionMode) {
      if (thumbnail.placeholder == FileThumbnailsPlaceholder.folder) {
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
