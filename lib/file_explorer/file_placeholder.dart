// Probably temporary the file type recognition should be done with the first bytes of the file content, not with the extension
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/file_viewers/audio.dart';
import 'package:life_chest/file_viewers/documents.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/file_viewers/image.dart';
import 'package:life_chest/vault.dart';

class FileThumbnailsPlaceholder {
  static final FileThumbnailsPlaceholder image = FileThumbnailsPlaceholder(
      const Icon(Icons.image, color: Colors.lightGreen, size: 128),
      [
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
      ],
          (Vault vault, File fileToRead, String fileName) => ImageViewer(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));
  static final FileThumbnailsPlaceholder documents = FileThumbnailsPlaceholder(
      const Icon(Icons.description, color: Colors.redAccent, size: 128),
      [
        'txt', // RAW TEXT
        'md', // MARKDOWN
        'pdf', // PORTABLE DOCUMENT FORMAT
        'json', 'dart', 'py', 'python', 'html', 'css', 'scss', 'gitignore', "xml"
        'yml',
        'yaml' // Other file formats
      ],
          (Vault vault, File fileToRead, String fileName) => DocumentViewer(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));
  static final FileThumbnailsPlaceholder videos = FileThumbnailsPlaceholder(
      const Icon(Icons.video_file, color: Colors.blueAccent, size: 128),
      [
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
      ],
          (Vault vault, File fileToRead, String fileName) => ImageViewer(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));
  static final archive = FileThumbnailsPlaceholder(
      const Icon(Icons.archive_outlined, color: Colors.deepPurpleAccent, size: 128),
      [
        'zip', // ZIP
        'rar', // RAR (WinRAR)
        '7z', // 7Z
        'tar', // TAR
        'jar', // JAR (java archive)
        'war', // WAR
        'gz', // GZIP
        'apk', // APK
      ],
          (Vault vault, File fileToRead, String fileName) => ImageViewer(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));
  static final audio = FileThumbnailsPlaceholder(
      const Icon(
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
        'webm' // WEBM
      ],
          (Vault vault, File fileToRead, String fileName) => AudioListener(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));
  static final unknown = FileThumbnailsPlaceholder(
      const Icon(Icons.question_mark, color: Colors.grey, size: 128),
      [],
          (Vault vault, File fileToRead, String fileName) => DocumentViewer(
          fileVault: vault, fileToRead: fileToRead, fileName: fileName));

  final Icon icon;
  final List<String> fileExtension;
  final FileViewer Function(Vault vault, File fileToRead, String fileName)
  invokeData;

  FileThumbnailsPlaceholder(
      this.icon, this.fileExtension, this.invokeData);

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
    in [FileThumbnailsPlaceholder.archive , FileThumbnailsPlaceholder.audio, FileThumbnailsPlaceholder.documents, FileThumbnailsPlaceholder.image, FileThumbnailsPlaceholder.videos, FileThumbnailsPlaceholder.unknown]) {
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
