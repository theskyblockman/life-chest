import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';

class ImageViewer extends FileViewer {
  Image? loadedImage;
  final FileReaderState explorerState;

  late bool isFullscreen;

  ImageViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData,
      required this.explorerState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GestureDetector(
          onTap: () async {
            explorerState.isFullscreen = !explorerState.isFullscreen;
          },
          onDoubleTap: () {
            explorerState.isPagingEnabled = !explorerState.isPagingEnabled;
            if (explorerState.isPagingEnabled == true) {
              explorerState.pageViewController =
                  PageController(initialPage: explorerState.oldPage!);
            }

            explorerState.update();
          },
          child: explorerState.isPagingEnabled
              ? loadedImage ?? Container()
              : InteractiveViewer(child: loadedImage ?? Container()),
        ));
  }

  @override
  Future<bool> load(BuildContext context) async {
    loadedImage = Image.memory(
        await SingleThreadedRecovery.loadAndDecryptFullFile(
            fileVault.encryptionKey!,
            fileToRead,
            Mac(List<int>.from(fileData['mac']))));
    return true;
  }

  @override
  bool get loaded => loadedImage != null;

  @override
  void dispose() {
    loadedImage = null;
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingImage;

  @override
  Future<void> onFocus() async {
    loadedImage ??= Image.memory(
        await SingleThreadedRecovery.loadAndDecryptFullFile(
            fileVault.encryptionKey!,
            fileToRead,
            Mac(List<int>.from(fileData['mac']))));
  }

  @override
  bool extendBody() => true;
}
