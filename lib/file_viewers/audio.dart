import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/file_recovery/native_recovery.dart';
import 'package:life_chest/vault.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioViewer extends StatefulWidget {
  final Vault fileVault;
  final File fileToRead;
  const AudioViewer({super.key, required this.fileVault, required this.fileToRead});

  @override
  State<StatefulWidget> createState() => AudioViewerState();
}

class AudioViewerState extends State<AudioViewer> {
  Uint8List? loadedMusic;
  final AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      if(snapshot.hasData) {
        return Center(child: FilledButton(child: const Text('send notification'), onPressed: () {
          const MethodChannel('theskyblockman.fr/channel').invokeMethod('createMediaNotification');
        },));
      } else {
        return Center(
            child: Opacity(
                opacity: 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text(
                      AppLocalizations.of(context)!.loadingAudioTrack,
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                    )
                  ],
                )));
      }
    }, future: load(),);
  }

  Future<bool> load() async {
    loadedMusic = await NativeRecovery.loadAndDecryptFile(widget.fileVault.encryptionKey!, widget.fileToRead);
    await player.setSourceBytes(loadedMusic!);
    await player.resume();
    return true;
  }

  @override
  void dispose() {
    loadedMusic = null;
    super.dispose();
  }
}