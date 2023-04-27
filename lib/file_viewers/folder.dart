import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';

class FolderViewer extends FileViewer {
  FolderViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(FileThumbnailsPlaceholder.folder.icon.icon,
          color: Colors.white,
          size: FileThumbnailsPlaceholder.folder.icon.size),
    );
  }

  @override
  void dispose() {}

  @override
  Future<bool> load() async {
    return true;
  }

  /// No needs for translation, the user wont see the folder load
  @override
  String loadingMessage(BuildContext context) => 'Loading folder';

  @override
  Future<void> onFocus() async {}
}
