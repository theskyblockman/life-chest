import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';

class AudioListener extends FileViewer {
  Uint8List? loadedMusic;
  final AudioPlayer player = AudioPlayer();

  AudioListener(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FilledButton(
      child: const Text('send notification'),
      onPressed: () {
        const MethodChannel('theskyblockman.fr/channel')
            .invokeMethod('createMediaNotification');
      },
    ));
  }

  @override
  Future<bool> load() async {
    loadedMusic = await SingleThreadedRecovery.loadAndDecryptFullFile(
        fileVault.encryptionKey!, fileToRead);
    await player.setSourceBytes(loadedMusic!);
    await player.resume();
    return true;
  }

  @override
  void dispose() {
    loadedMusic = null;
  }

  @override
  String loadingMessage(BuildContext context) =>
      AppLocalizations.of(context)!.loadingAudioTrack;
}
