import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:path/path.dart';

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
    return Container(
      child: documentType == DocumentType.pdf
          ? PDFView(
        gestureRecognizers: {
          Factory(() => VerticalDragGestureRecognizer()),
        },
          nightMode: MediaQuery.of(context).platformBrightness == Brightness.dark,
          pdfData: loadedDocument,
          pageSnap: false,
          onLinkHandler: (uri) {
            if(uri != null) {
              Clipboard.setData(ClipboardData(text: uri));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).linkCopied)));
            }
          })
          : SingleChildScrollView(child: Text(utf8.decode(loadedDocument!))),
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
