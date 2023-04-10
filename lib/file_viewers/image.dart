import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';

class ImageViewer extends FileViewer {
  Image? loadedImage;

  ImageViewer({required super.fileVault, required super.fileToRead, required super.fileName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        clipBehavior: Clip.none, child: loadedImage!));
  }

  @override
  Future<bool> load() async {
    loadedImage = Image.memory(await SingleThreadedRecovery.loadAndDecryptFullFile(
        fileVault.encryptionKey!, fileToRead));
    return true;
  }

  @override
  void dispose() {
    loadedImage = null;
  }

  @override
  String loadingMessage(BuildContext context) => AppLocalizations.of(context)!.loadingImage;
}
