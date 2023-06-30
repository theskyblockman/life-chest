import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum DocumentType {
  pdf,
  plainText,
}

class DocumentViewer extends FileViewer {
  late DocumentType documentType;
  Uint8List? loadedDocument;

  DocumentViewer(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});

  @override
  Widget build(BuildContext context) {
    debugPrint(loadedDocument.toString());
    return Container(
      child: documentType == DocumentType.pdf
          ? SfPdfViewer.memory(loadedDocument!)
          : SingleChildScrollView(child: Text(utf8.decode(loadedDocument!), style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Future<bool> load(BuildContext context) async {
    documentType = basename(fileName).endsWith('pdf')
        ? DocumentType.pdf
        : DocumentType.plainText;
    loadedDocument = await SingleThreadedRecovery.loadAndDecryptFullFile(
        fileVault.encryptionKey!, fileToRead);
    return true;
  }

  @override
  void dispose() {
    loadedDocument = null;
  }

  @override
  String loadingMessage(BuildContext context) => S.of(context).loadingDocuments;

  @override
  Future<void> onFocus() async {}

  @override
  bool extendBody() => false;
}
