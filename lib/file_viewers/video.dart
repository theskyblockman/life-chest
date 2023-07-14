import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:path/path.dart';

class VideoViewer extends FileViewer {
  VideoViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});
  late BetterPlayerDataSource dataSource;

  BetterPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.black, child: Center(child: BetterPlayer(controller: controller!)));
  }

  @override
  void dispose() {
    controller!
        .pause()
        .then((value) => controller!.dispose(forceDispose: true));
  }

  @override
  Future<bool> load(BuildContext context) async {
    dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.memory, '',
        bytes: await SingleThreadedRecovery.loadAndDecryptFullFile(
            fileVault.encryptionKey!, fileToRead), videoExtension: extension(fileName));

    // ignore: use_build_context_synchronously
    if(!context.mounted) return false;

    controller = BetterPlayerController(BetterPlayerConfiguration(
        allowedScreenSleep: false,
        autoDetectFullscreenAspectRatio: true,
        autoDispose: false,
        autoPlay: false,
        looping: true,
        autoDetectFullscreenDeviceOrientation: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(),
        aspectRatio: fileData['videoData']['streams'][0]['width'] / fileData['videoData']['streams'][0]['height'],
        fit: BoxFit.contain,
        translations: [
          BetterPlayerTranslations(),
          BetterPlayerTranslations(
              languageCode: 'fr',
              generalDefaultError: 'La vidéo ne peut pas être jouée',
              generalNone: 'Aucun',
              generalDefault: 'Défaut',
              generalRetry: 'Réessayer',
              playlistLoadingNextVideo: "Chargement de la prochaine vidéo",
              controlsLive: "DIRECT",
              controlsNextVideoIn: "Prochaine vidéo dans",
              overflowMenuPlaybackSpeed: "Vitesse de lecture",
              overflowMenuSubtitles: "Sous-titres",
              overflowMenuQuality: "Qualité",
              overflowMenuAudioTracks: "Audio",
              qualityAuto: "Auto"
          )
        ]
    ),
        betterPlayerDataSource: dataSource,
        betterPlayerPlaylistConfiguration:
            const BetterPlayerPlaylistConfiguration(
                loopVideos: true, initialStartIndex: 0));

    return true;
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingVideo;

  @override
  Future<void> onFocus() async {
    if (controller != null) {
      controller!.setOverriddenAspectRatio(
          controller!.videoPlayerController!.value.aspectRatio);
      controller!.play();
    }
  }

  @override
  bool extendBody() => false;
}
