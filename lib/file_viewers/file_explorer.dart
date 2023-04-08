import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/audio.dart';
import 'package:life_chest/file_viewers/documents.dart';
import 'package:life_chest/file_viewers/image.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';

class FileThumbnail extends StatelessWidget {
  final String name;
  final String localPath;
  final FileThumbnailsPlaceholder placeholder;
  final File file;
  final Vault vault;
  final void Function(BuildContext context, FileThumbnail state) onPress;
  final void Function(FileThumbnail state) onLongPress;
  final bool isSelected;

  const FileThumbnail(
      {super.key,
      required this.localPath,
      required this.name,
      required this.placeholder,
      required this.file,
      required this.vault,
      required this.onPress,
      required this.onLongPress,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: () => onLongPress(this),
        onTap: () => onPress(context, this),
        child: GridTile(
            child: Container(
          decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(.1)),
          child: Column(children: [
            placeholder.icon,
            Text(name, overflow: TextOverflow.ellipsis)
          ]),
        )));
  }
}

class FileReader extends StatefulWidget {
  final List<FileThumbnail> thumbnails;
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

  Widget readFile(FileThumbnail thumbnail) {
    switch (thumbnail.placeholder) {
      case FileThumbnailsPlaceholder.audio:
        return AudioViewer(
            fileVault: widget.fileVault, fileToRead: thumbnail.file);
      case FileThumbnailsPlaceholder.documents:
      case FileThumbnailsPlaceholder.archive:
      case FileThumbnailsPlaceholder.unknown:
        return DocumentViewer(
            fileVault: widget.fileVault,
            fileToRead: thumbnail.file,
            fileName: thumbnail.name);
      case FileThumbnailsPlaceholder.videos:
      case FileThumbnailsPlaceholder.image:
        return ImageViewer(
            fileVault: widget.fileVault, fileToRead: thumbnail.file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemBuilder: (context, index) {
          FileThumbnail currentThumbnail = widget.thumbnails[index];
          return Scaffold(
              appBar: AppBar(title: Text(currentThumbnail.name)),
              body: readFile(currentThumbnail));
        },
        itemCount: widget.thumbnails.length,
        scrollDirection: Axis.horizontal,
        controller: pageViewController);
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
  const RenameWindow({super.key, required this.onOkButtonPressed, required this.onCancelButtonPressed, required this.initialName});

  @override
  State<StatefulWidget> createState() => RenameWindowState();

}

class RenameWindowState extends State<RenameWindow> {
  late final TextEditingController renameFieldController;
  bool hasNotChanged = true;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text(AppLocalizations.of(context)!.rename), content: TextField(autofocus: true, textInputAction: TextInputAction.none, controller: renameFieldController, decoration: const InputDecoration(border: OutlineInputBorder()), onChanged: (value) {
      bool oldValue = hasNotChanged;
      hasNotChanged = value == widget.initialName;
      if(oldValue != hasNotChanged) {
        setState(() {});
      }
    }), actions: [
      TextButton(onPressed: widget.onCancelButtonPressed, child: Text(AppLocalizations.of(context)!.cancel)),
      TextButton(onPressed: hasNotChanged ? null : () => widget.onOkButtonPressed(renameFieldController.text), child: Text(AppLocalizations.of(context)!.ok)),
    ]);
  }

  @override
  void initState() {
    renameFieldController = TextEditingController(text: widget.initialName);
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

  @override
  Widget build(BuildContext context) {
    thumbnailSize ??= MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? 4
            : 2);
    thumbnailCollector ??= reloadThumbnails();

    return Scaffold(
      appBar: AppBar(
          actions: isSelectionMode
              ? [
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    itemBuilder: (context) {
                      return [
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
                                FileThumbnail selectedThumbnail = thumbnails.firstWhere((element) => element.isSelected);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  showDialog<bool>(context: context, builder: (context) {
                                    return RenameWindow(onOkButtonPressed: (newName) async {
                                      map[selectedThumbnail.localPath] = newName;
                                      File(join(widget.vault.path, '.map')).writeAsBytesSync((await VaultsManager.encryptMap(widget.vault, map))!);
                                      isSelectionMode = false;
                                      thumbnailCollector = reloadThumbnails();
                                      if(context.mounted) Navigator.of(context).pop(true);
                                    }, onCancelButtonPressed: () {
                                      Navigator.of(context).pop(false);
                                    }, initialName: selectedThumbnail.name);
                                  },).then((value) {
                                    if(value == true) { // NOTE: Do not edit this, as the value can be null it saves 1 instruction to try to put value as true as to verify that it isn't null and to then verify it's bool value
                                      setState(() {});
                                    }
                                  });
                                });

                              },
                              child:
                                  Text(AppLocalizations.of(context)!.rename)),
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
                                            placeholder: thumbnail.placeholder,
                                            file: thumbnail.file,
                                            vault: thumbnail.vault,
                                            onPress: thumbnail.onPress,
                                            onLongPress: thumbnail.onLongPress,
                                            isSelected: true);
                                  }
                                }
                                amountOfFilesSelected = thumbnails.length;
                              });
                            },
                            child:
                                Text(AppLocalizations.of(context)!.selectAll))
                      ];
                    },
                  )
                ]
              : null,
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
                                placeholder: thumbnail.placeholder,
                                file: thumbnail.file,
                                vault: thumbnail.vault,
                                onPress: thumbnail.onPress,
                                onLongPress: thumbnail.onLongPress,
                                isSelected: false);
                      }
                    }
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              icon: isSelectionMode
                  ? const Icon(Icons.close)
                  : const Icon(Icons.arrow_back)),
          title: Text(isSelectionMode
              ? AppLocalizations.of(context)!.selected(amountOfFilesSelected)
              : widget.vault.name),
          bottom: loaderTarget == null || loaderCurrentLoad == null ? null : PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(value: loaderCurrentLoad! / loaderTarget!)),
          backgroundColor: isSelectionMode
              ? Theme.of(context).colorScheme.tertiary.withOpacity(.7)
              : null),
      floatingActionButton: FloatingActionButton.large(
          onPressed: () async {
            saveFiles(context);
          },
          child: const Icon(Icons.add)),
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
    );
  }

  Future<void> saveFiles(BuildContext context) async {
    File mapFile =
    File(join(widget.vault.path, '.map'));
    mapFile.createSync(recursive: true);
    try {
      List<File>? selectedFiles = await SingleThreadedRecovery.pickFilesToSave(dialogTitle: AppLocalizations.of(context)!.pickFilesDialogTitle);

      if(selectedFiles == null || selectedFiles.isEmpty) {
        return;
      }
      setState(() {
        loaderTarget = selectedFiles.length;
        loaderCurrentLoad = 0;
      });

      Map<String, String> savedFiles = {};

      await for(MapEntry<String, String> savedFile in SingleThreadedRecovery.progressivelySaveFiles(
          widget.vault.encryptionKey!,
          widget.vault.path,
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
          oldMap: map,
          additionalFiles:
          savedFiles);
      mapFile.writeAsBytesSync(
          (await VaultsManager.encryptMap(
              widget.vault, map))!);

      setState(() {
        thumbnailCollector = reloadThumbnails();
      });
    } on PlatformException {
      return;
    }
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

    for (MapEntry<String, dynamic> mappedFile in map.entries) {
      ValueKey<String> thumbnailKey = ValueKey(mappedFile.key);
      createdThumbnails.add(FileThumbnail(
          key: thumbnailKey,
          localPath: mappedFile.key,
          name: mappedFile.value,
          placeholder: fileTypes[mappedFile.value]!,
          file: File(join(widget.vault.path, mappedFile.key)),
          vault: widget.vault,
          onPress: thumbnailTap,
          onLongPress: thumbnailLongTap,
          isSelected: false));
    }

    thumbnails = createdThumbnails;

    return true;
  }

  void thumbnailTap(BuildContext context, FileThumbnail thumbnail) {
    if (!isSelectionMode) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FileReader(
                  thumbnails: thumbnails,
                  fileVault: widget.vault,
                  initialThumbnail: thumbnails.indexOf(thumbnail))));
      return;
    }
    setState(() {
      thumbnails[thumbnails.indexOf(thumbnail)] = FileThumbnail(
          localPath: thumbnail.localPath,
          name: thumbnail.name,
          placeholder: thumbnail.placeholder,
          file: thumbnail.file,
          vault: thumbnail.vault,
          onPress: thumbnail.onPress,
          onLongPress: thumbnail.onLongPress,
          isSelected: !thumbnail.isSelected);
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
          placeholder: thumbnail.placeholder,
          file: thumbnail.file,
          vault: thumbnail.vault,
          onPress: thumbnail.onPress,
          onLongPress: thumbnail.onLongPress,
          isSelected: true);
    });
  }
}

// Probably temporary the file type recognition should be done with the first bytes of the file content, not with the extension
enum FileThumbnailsPlaceholder {
  image(Icon(Icons.image, color: Colors.lightGreen, size: 128), [
    'jpg', 'jpeg', 'jpe', 'jif', 'jfif', 'jfi', // JPG
    'png', // PNG
    'gif', // GIF
    'webp', // WEBP
    'tif', 'tiff', // TIFF
    'raw', 'arw', 'cr2', 'nrw', 'k25', // RAW
    'bmp', 'dib', // BMP
    'heif', // HEIF
    'ind', 'indd', 'indt', // INDD
    'jp2', 'j2k', 'jpf', 'jpx', 'jpm', 'mj2', // JPEG 2000
    'svg', 'svgz' // SVG
  ]),
  documents(Icon(Icons.description, color: Colors.redAccent, size: 128), [
    'txt', // RAW TEXT
    'md', // MARKDOWN
    'pdf', // PORTABLE DOCUMENT FORMAT
    'json', 'dart', 'py', 'python', 'html', 'css', 'scss', '.gitignore', 'yml',
    'yaml' // Other file formats
  ]),
  videos(Icon(Icons.video_file, color: Colors.blueAccent, size: 128), [
    'webm', // WEBM
    'mkv', // Matroska
    'flv', // Flash Video / F4V
    'vob', // Vob
    'drc', // Dirac
    'gifv', // GIFV
    'avi', // AVI
    'mts', 'm2ts', 'ts', // MPEG TS
    'amv', // AMV
    'mp4', 'm4p', 'm4v', // MPEG 4
    'mpg', 'mpeg', // MPEG 1/2
    'mp2', 'mpe', 'mpv', // MPEG 1
    'm2v', // MPEG 2
    'm4v', // M4V
    'svi', // SVI
    '3gp', // 3GPP
    '3g2' // 3GPP2
  ]),
  archive(
      Icon(Icons.archive_outlined, color: Colors.deepPurpleAccent, size: 128), [
    'zip', // ZIP
    'rar', // RAR (WinRAR)
    '7z', // 7Z
    'tar', // TAR
    'jar', // JAR (java archive)
    'war', // WAR
    'gz', // GZIP
    'apk', // APK
  ]),
  audio(
      Icon(
        Icons.audiotrack_outlined,
        color: Colors.amberAccent,
        size: 128,
      ),
      [
        'm4a', // MP4 audio only
        'm3b', // MP4 audio only for podcasts/audio books
        'mp3', // MP3
        'ogg', 'oga', 'mogg', // OGG
        'opus', // OPUS
        'wav', // WAV
        'wabm' // WEBM
      ]),
  unknown(Icon(Icons.question_mark, color: Colors.grey, size: 128), []);

  final Icon icon;
  final List<String> fileExtension;

  const FileThumbnailsPlaceholder(this.icon, this.fileExtension);

  /// OPTIMIZED for big data
  static Map<String, FileThumbnailsPlaceholder> getPlaceholderFromFileName(
      List<String> fileNames) {
    Map<String, FileThumbnailsPlaceholder> foundFileTypes = {};
    Map<String, String> notFoundFileNames = {};

    for (String fileName in fileNames) {
      if (!fileName.contains('.')) {
        foundFileTypes[fileName] = FileThumbnailsPlaceholder.unknown;
        continue;
      }

      String fileExtension = fileName.split('.').last.toLowerCase();
      notFoundFileNames[fileName] = fileExtension;
    }

    for (FileThumbnailsPlaceholder placeholder
        in FileThumbnailsPlaceholder.values) {
      for (String possibleExtension in placeholder.fileExtension) {
        for (MapEntry<String, String> fileNameToTest
            in Map<String, String>.from(notFoundFileNames).entries) {
          if (fileNameToTest.value == possibleExtension) {
            foundFileTypes[fileNameToTest.key] = placeholder;
            notFoundFileNames.remove(fileNameToTest.key);
          }
        }
      }
    }
    for (MapEntry<String, String> notFoundFileType
        in notFoundFileNames.entries) {
      foundFileTypes[notFoundFileType.key] = FileThumbnailsPlaceholder.unknown;
    }
    return foundFileTypes;
  }
}
