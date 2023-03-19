import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:life_chest/file_recovery/multithreaded_recovery.dart';
import 'package:life_chest/vault.dart';

class ImageViewer extends StatefulWidget {
  final Vault fileVault;
  final File fileToRead;
  const ImageViewer({super.key, required this.fileVault, required this.fileToRead});

  @override
  State<StatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  late Uint8List loadedImage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      if(snapshot.hasData) {
        return Center(child: InteractiveViewer(clipBehavior: Clip.none,child: Image.memory(loadedImage),),);
      } else {
        return Container();
      }
    }, future: load(),);
  }

  Future<bool> load() async {
    loadedImage = await MultithreadedRecovery.loadAndDecryptFile(widget.fileVault.encryptionKey!, widget.fileToRead);
    return true;
  }
}