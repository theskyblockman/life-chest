import 'package:flutter/material.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';

class ImageViewer extends FileViewer {
  Image? loadedImage;
  final FileReaderState explorerState;
  final TransformationController controller = TransformationController();

  ImageViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData, required this.explorerState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: InteractiveViewer(
            clipBehavior: Clip.none, constrained: true, transformationController: controller, onInteractionEnd: (details) {
                explorerState.isPagingEnabled = controller.value.getMaxScaleOnAxis() <= 1.0;
            }, child: loadedImage!)
    );
  }

  @override
  Future<bool> load() async {
    loadedImage = Image.memory(
        await SingleThreadedRecovery.loadAndDecryptFullFile(
            fileVault.encryptionKey!, fileToRead));
    return true;
  }

  @override
  void dispose() {
    loadedImage = null;
  }

  @override
  String loadingMessage(BuildContext context) =>
      S.of(context).loadingImage;

  @override
  Future<void> onFocus() async {}
}
