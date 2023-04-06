import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../vault.dart';

enum DocumentType {
  pdf,
  plainText,
}

class DocumentViewer extends StatefulWidget {
  final Vault fileVault;
  final File fileToRead;
  final String fileName;

  const DocumentViewer(
      {super.key,
      required this.fileVault,
      required this.fileToRead,
      required this.fileName});

  @override
  State<StatefulWidget> createState() => DocumentViewerState();
}

class DocumentViewerState extends State<DocumentViewer> {
  late DocumentType documentType;
  Uint8List? loadedDocument;

  @override
  void initState() {
    documentType = basename(widget.fileName).endsWith('pdf')
        ? DocumentType.pdf
        : DocumentType.plainText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: documentType == DocumentType.pdf
                ? SfPdfViewer.memory(loadedDocument!)
                : SingleChildScrollView(
                    child: Text(utf8.decode(loadedDocument!))),
          );
        } else {
          return Center(
              child: Opacity(
                  opacity: 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      Text(
                        AppLocalizations.of(context)!.loadingDocuments,
                        textScaleFactor: 2.5,
                        textAlign: TextAlign.center,
                      )
                    ],
                  )));
        }
      },
      future: load(),
    );
  }

  Future<bool> load() async {
    loadedDocument = await SingleThreadedRecovery.loadAndDecryptFullFile(
        widget.fileVault.encryptionKey!, widget.fileToRead);
    return true;
  }

  @override
  void dispose() {
    loadedDocument = null;
    super.dispose();
  }
}
