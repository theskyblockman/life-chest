import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';

class VideoViewer extends FileViewer {
  VideoViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});
  late BetterPlayerDataSource dataSource;
  static const BetterPlayerConfiguration config = BetterPlayerConfiguration(
    allowedScreenSleep: true,
    autoDetectFullscreenAspectRatio: true,
    autoDispose: false,
    autoPlay: false,
    autoDetectFullscreenDeviceOrientation: true,
    controlsConfiguration: BetterPlayerControlsConfiguration(enableQualities: false, backwardSkipTimeInMilliseconds: 5000, enableFullscreen: true, enableProgressBar: true, showControls: true)
  );
  late BetterPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: controller);
  }

  @override
  void dispose() {
    controller.pause().then((value) => controller.dispose(forceDispose: true));
  }

  @override
  Future<bool> load() async {
    dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.memory, '', bytes: await SingleThreadedRecovery.loadAndDecryptFullFile(fileVault.encryptionKey!, fileToRead));
    controller = BetterPlayerController(config, betterPlayerDataSource: dataSource, betterPlayerPlaylistConfiguration: const BetterPlayerPlaylistConfiguration(loopVideos: true, initialStartIndex: 0));

    return true;
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingVideo;

  @override
  Future<void> onFocus() async {
    controller.play();
  }

  @override
  bool extendBody() => true;
}
