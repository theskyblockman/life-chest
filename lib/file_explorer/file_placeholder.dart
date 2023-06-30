import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_viewers/audio.dart';
import 'package:life_chest/file_viewers/documents.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/file_viewers/folder.dart';
import 'package:life_chest/file_viewers/image.dart';
import 'package:life_chest/file_viewers/video.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';

/// All the types of thumbnail that can be detected
class FileThumbnailsPlaceholder {
  static final FileThumbnailsPlaceholder folder = FileThumbnailsPlaceholder(
      const Icon(Icons.folder, size: 128, color: Colors.amberAccent),
      'folder',
      (vault, fileToRead, fileName, fileData, explorerState) => FolderViewer(
          fileVault: vault,
          fileToRead: fileToRead,
          fileName: fileName,
          fileData: fileData));

  static final FileThumbnailsPlaceholder image = FileThumbnailsPlaceholder(
      const Icon(Icons.image, color: Colors.lightGreen, size: 128),
      'image',
      (Vault vault, File fileToRead, String fileName,
              Map<String, dynamic> fileData, FileReaderState explorerState) =>
          ImageViewer(
              fileVault: vault,
              fileToRead: fileToRead,
              fileName: fileName,
              fileData: fileData,
              explorerState: explorerState));
  static final FileThumbnailsPlaceholder documents =
      FileThumbnailsPlaceholder.multipleSignatures(
          const Icon(Icons.description, color: Colors.redAccent, size: 128),
          ['text', '.pdf'],
          (Vault vault,
                  File fileToRead,
                  String fileName,
                  Map<String, dynamic> fileData,
                  FileReaderState explorerState) =>
              DocumentViewer(
                  fileVault: vault,
                  fileToRead: fileToRead,
                  fileName: fileName,
                  fileData: fileData));
  static final FileThumbnailsPlaceholder videos = FileThumbnailsPlaceholder(
      const Icon(Icons.video_file, color: Colors.blueAccent, size: 128),
      'video',
      (Vault vault, File fileToRead, String fileName,
              Map<String, dynamic> fileData, FileReaderState explorerState) =>
          VideoViewer(
              fileVault: vault,
              fileToRead: fileToRead,
              fileName: fileName,
              fileData: fileData));
  static final archive = FileThumbnailsPlaceholder.multipleSignatures(
      const Icon(Icons.archive_outlined,
          color: Colors.deepPurpleAccent, size: 128),
      [
        '.zip', // ZIP
        '.x-rar-compressed', // RAR (WinRAR)
        '.x-7z-compressed', // 7Z
        '.x-tar', // TAR
        '.java-archive', // JAR
        '.gzip', // GZIP
        '.apk', // APK
      ],
      (Vault vault, File fileToRead, String fileName,
              Map<String, dynamic> fileData, FileReaderState explorerState) =>
          ImageViewer(
              fileVault: vault,
              fileToRead: fileToRead,
              fileName: fileName,
              fileData: fileData,
              explorerState: explorerState));
  static final audio = FileThumbnailsPlaceholder.multipleSignatures(
      const Icon(
        Icons.audiotrack_outlined,
        color: Colors.amberAccent,
        size: 128,
      ),
      ['audio', '.ogg', '.opus'],
      (Vault vault, File fileToRead, String fileName,
              Map<String, dynamic> fileData, FileReaderState explorerState) =>
          AudioListener(
              fileVault: vault,
              fileToRead: fileToRead,
              fileName: fileName,
              fileData: fileData));
  static final unknown = FileThumbnailsPlaceholder.multipleSignatures(
      const Icon(Icons.question_mark, color: Colors.grey, size: 128),
      ['unknown', '.*'],
      (Vault vault, File fileToRead, String fileName,
              Map<String, dynamic> fileData, FileReaderState explorerState) =>
          DocumentViewer(
              fileVault: vault,
              fileToRead: fileToRead,
              fileName: fileName,
              fileData: fileData));

  final Icon icon;
  final List<String> mimeSignatures;
  final FileViewer Function(Vault vault, File fileToRead, String fileName,
      Map<String, dynamic> fileData, FileReaderState explorerState) invokeData;

  static final List<FileThumbnailsPlaceholder> values = [
    folder,
    archive,
    audio,
    documents,
    image,
    videos,
    unknown
  ];

  FileThumbnailsPlaceholder(this.icon, String mimeSignature, this.invokeData)
      : mimeSignatures = [mimeSignature];

  FileThumbnailsPlaceholder.multipleSignatures(
      this.icon, this.mimeSignatures, this.invokeData);

  /// The data given with the file path should be its first decoded chunk to get its signing bytes
  static Map<String, FileThumbnailsPlaceholder> getPlaceholderFromFileName(
      List<Map<String, dynamic>> files) {
    Map<String, FileThumbnailsPlaceholder> foundResults = {};

    for (Map<String, dynamic> fileData in files) {
      String fileExtension = extension(fileData['name']!);
      String? mimeType = fileData['type'];
      bool found = false;
      for (FileThumbnailsPlaceholder thumbnailType in values) {
        for (String signature in thumbnailType.mimeSignatures) {
          if (fileExtension.contains(signature) ||
              (mimeType == null ? false : mimeType.contains(signature))) {
            foundResults[fileData['name']!] = thumbnailType;
            found = true;
            break;
          }
        }
        if (found) {
          found = false;
          break;
        }
      }
    }

    return foundResults;
  }
}
