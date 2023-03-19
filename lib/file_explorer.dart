import 'dart:io';
import 'package:flutter/material.dart';
import 'package:life_chest/file_viewers/image.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';
import 'package:life_chest/file_recovery/multithreaded_recovery.dart';

class FileThumbnail extends StatefulWidget {
  final String name;
  final String localPath;
  final FileThumbnailsPlaceholder placeholder;
  final double thumbnailSize;
  final File file;
  final Vault vault;
  const FileThumbnail({super.key, required this.localPath, required this.name, required this.placeholder, required this.thumbnailSize, required this.file, required this.vault});

  @override
  State<StatefulWidget> createState() => FileThumbnailState();
}

class FileThumbnailState extends State<FileThumbnail> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FileReader(originalThumbnail: widget, fileVault: widget.vault)));
    }, child: Container(margin: EdgeInsets.zero, padding: const EdgeInsets.symmetric(horizontal: 2.5), constraints: BoxConstraints(minHeight: widget.thumbnailSize, maxWidth: widget.thumbnailSize), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5)), child: Column(children: [
      widget.placeholder.icon,
      Text(widget.name, overflow: TextOverflow.ellipsis)
    ])));
  }
}

class FileReader extends StatefulWidget {
  final FileThumbnail originalThumbnail;
  final Vault fileVault;
  const FileReader({super.key, required this.originalThumbnail, required this.fileVault});

  @override
  State<StatefulWidget> createState() => FileReaderState();
}

class FileReaderState extends State<FileReader> {



  Widget readFile() {
    switch(widget.originalThumbnail.placeholder) {
      case FileThumbnailsPlaceholder.documents:
      case FileThumbnailsPlaceholder.videos:
      case FileThumbnailsPlaceholder.archive:
      case FileThumbnailsPlaceholder.audio:
      case FileThumbnailsPlaceholder.unknown:
      case FileThumbnailsPlaceholder.image:
        return ImageViewer(fileVault: widget.fileVault, fileToRead: widget.originalThumbnail.file);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.originalThumbnail.name)), body: readFile());
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

  @override
  Widget build(BuildContext context) {
    thumbnailSize ??= MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? 4 : 2);
    thumbnailCollector ??= reloadThumbnails();

    return Scaffold(appBar: AppBar(title: Text(widget.vault.name), bottom: const PreferredSize(preferredSize: Size.fromHeight(3), child: LinearProgressIndicator(value: 0.5,))), floatingActionButton: FloatingActionButton.large(onPressed: () async {
      File mapFile = File(join(widget.vault.path, '.map'));
      mapFile.createSync(recursive: true);

      map = VaultsManager.constructMap(widget.vault, oldMap: map, additionalFiles: await MultithreadedRecovery.saveFilesForMultithreadedDecryption(widget.vault.encryptionKey!, widget.vault.path));
      mapFile.writeAsStringSync(VaultsManager.encryptMap(widget.vault, map)!);

      setState(() {
        thumbnailCollector = reloadThumbnails();
      });
    }, child: const Icon(Icons.add)), body: FutureBuilder(future: thumbnailCollector, builder: (context, snapshot) {
      if(snapshot.hasData) {
        return thumbnails.isNotEmpty ? GridView.count(crossAxisCount: MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? 4 : 2, children: thumbnails) : Center(
            child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Opacity(opacity: 0.45, child: Text(
                      'No files added yet',
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                    )),
                    FilledButton.tonal(onPressed: () async {
                      File mapFile = File(join(widget.vault.path, '.map'));
                      mapFile.createSync(recursive: true);

                      map = VaultsManager.constructMap(widget.vault, oldMap: map, additionalFiles: await MultithreadedRecovery.saveFilesForMultithreadedDecryption(widget.vault.encryptionKey!, widget.vault.path));
                      mapFile.writeAsStringSync(VaultsManager.encryptMap(widget.vault, map)!);

                      setState(() {
                        thumbnailCollector = reloadThumbnails();
                      });
                    } , child: const Text('Add files'))
                  ],
                )
        );
      } else {
        return const Center(
            child: Opacity(
                opacity: 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.watch_later, size: 120),
                    Text(
                      'Loading elements...',
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                    )
                  ],
                )));
      }
    },),);
  }

  Future<bool> reloadThumbnails() async {
    File mapFile = File(join(widget.vault.path, '.map'));
    if(!mapFile.existsSync()) {
      return false;
    }

    map = VaultsManager.decryptMap(widget.vault, mapFile.readAsStringSync())!;
    List<FileThumbnail> createdThumbnails = [];

    keepThumbnailsLoaded = map.length <= 20;

    Map<String, FileThumbnailsPlaceholder> fileTypes = FileThumbnailsPlaceholder.getPlaceholderFromFileName(List.from(map.values));

    for(MapEntry<String, dynamic> mappedFile in map.entries) {
      createdThumbnails.add(FileThumbnail(localPath: mappedFile.key, name: mappedFile.value, placeholder: fileTypes[mappedFile.value]!, thumbnailSize: thumbnailSize!, file: File(join(widget.vault.path, mappedFile.key)), vault: widget.vault,));
    }

    thumbnails = createdThumbnails;

    return true;
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
    'pdf' // PORTABLE DOCUMENT FORMAT
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
  archive(Icon(Icons.archive_outlined, color: Colors.deepPurpleAccent, size: 128), [
    'zip', // ZIP
    'rar', // RAR (WinRAR)
    '7z', // 7Z
    'tar', // TAR
    'jar', // JAR (java archive)
    'war', // WAR
    'gz', // GZIP
    'apk', // APK
  ]),
  audio(Icon(Icons.audiotrack_outlined, color: Colors.amberAccent, size: 128,), [
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
  static Map<String, FileThumbnailsPlaceholder> getPlaceholderFromFileName(List<String> fileNames) {
    Map<String, FileThumbnailsPlaceholder> foundFileTypes = {};
    Map<String, String> notFoundFileNames = {};

    for(String fileName in fileNames) {
      if(!fileName.contains('.')) {
        foundFileTypes[fileName] = FileThumbnailsPlaceholder.unknown;
        continue;
      }

      String fileExtension = fileName.split('.').last.toLowerCase();
      notFoundFileNames[fileName] = fileExtension;
    }

    for(FileThumbnailsPlaceholder placeholder in FileThumbnailsPlaceholder.values) {
      for(String possibleExtension in placeholder.fileExtension) {
        for(MapEntry<String, String> fileNameToTest in Map<String, String>.from(notFoundFileNames).entries) {
          if(fileNameToTest.value == possibleExtension) {
            foundFileTypes[fileNameToTest.key] = placeholder;
            notFoundFileNames.remove(fileNameToTest.key);
          }
        }
      }
    }
    for(MapEntry<String, String> notFoundFileType in notFoundFileNames.entries) {
      foundFileTypes[notFoundFileType.key] = FileThumbnailsPlaceholder.unknown;
    }
    return foundFileTypes;
  }
}