import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends FileViewer {
  VideoViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});
  ChewieController? controller;
  late File videoFile;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.black,
        child: Center(child: Chewie(controller: controller!)));
  }

  @override
  void dispose() {
    controller!.pause().then((value) => controller!.dispose());
    Future.delayed(const Duration(seconds: 30)).then((value) => videoFile.deleteSync());
  }

  @override
  Future<bool> load(BuildContext context) async {
    videoFile =
        File(join((await getTemporaryDirectory()).path, basename(fileName)));
    if (!videoFile.existsSync() ||
        videoFile.statSync().size != fileToRead.statSync().size) {
      await videoFile.openWrite().addStream(
          await SingleThreadedRecovery.loadAndDecryptFile(
              fileVault.encryptionKey!,
              fileToRead,
              Mac(List<int>.from(fileData['mac']))));
    }

    // ignore: use_build_context_synchronously
    if (!context.mounted) return false;

    controller ??= ChewieController(
        autoPlay: true,
        looping: true,
        aspectRatio:
            fileData['videoData']['width'] / fileData['videoData']['height'],
        videoPlayerController: VideoPlayerController.file(videoFile,
            videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: false, mixWithOthers: true)));

    return true;
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingVideo;

  @override
  Future<void> onFocus() async {
    if (controller != null) {
      controller!.play();
    }
  }

  @override
  bool extendBody() => false;
}
