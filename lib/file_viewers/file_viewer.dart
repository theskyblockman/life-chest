import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/vault.dart';

abstract class FileViewer {
  Widget build(BuildContext context);
  Future<bool> load();
  Future<void> onFocus();
  void dispose();
  String loadingMessage(BuildContext context);
  final Vault fileVault;
  final File fileToRead;
  final String fileName;
  final Map<String, dynamic> fileData;

  const FileViewer(
      {required this.fileVault,
      required this.fileToRead,
      required this.fileName,
      required this.fileData});
}
