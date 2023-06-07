import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/vault.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:marquee/marquee.dart';

/// Represents a [FileThumbnail] data-wise
class FileThumbnail extends StatelessWidget {
  final String name;
  final String localPath;
  final String fullLocalPath;
  final FileThumbnailsPlaceholder placeholder;
  final File file;
  final Vault vault;
  final void Function(BuildContext context, FileThumbnail state) onPress;
  final void Function(FileThumbnail state) onLongPress;
  final bool isSelected;
  final Map<String, dynamic> data;

  const FileThumbnail(
      {super.key,
      required this.localPath,
      required this.name,
      required this.fullLocalPath,
      required this.placeholder,
      required this.file,
      required this.vault,
      required this.onPress,
      required this.onLongPress,
      required this.isSelected,
      required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => onLongPress(this),
      onTap: () => onPress(context, this),
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isSelected
                ? Theme.of(context).colorScheme.tertiary.withOpacity(.3)
                : Theme.of(context).colorScheme.outline.withOpacity(.1),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final textSpan = TextSpan(text: name, style: DefaultTextStyle.of(context).style);
              final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
                maxLines: 1,
              );
              textPainter.layout(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);

              if (!textPainter.didExceedMaxLines) {
                return Column(
                  children: [
                    placeholder.icon,
                    Text(name),
                  ],
                );
              } else {
                return Column(
                  children: [
                    placeholder.icon,
                    Expanded(
                      child: Marquee(text: name, crossAxisAlignment: CrossAxisAlignment.center, blankSpace: 20, fadingEdgeStartFraction: 1/2, fadingEdgeEndFraction: 1/2, showFadingOnlyWhenScrolling: false),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

}
