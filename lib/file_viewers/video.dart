import 'package:flutter/material.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';

class VideoViewer extends FileViewer {
  VideoViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<bool> load() {
    // TODO: implement load
    throw UnimplementedError();
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingImage;

  @override
  Future<void> onFocus() async {}

  @override
  bool extendBody() => true;
}
