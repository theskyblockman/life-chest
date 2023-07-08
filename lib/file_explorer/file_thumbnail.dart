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
  final bool isGridView;

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
      required this.data,
      required this.isGridView});

  FileThumbnail copyWith(
      {String? name,
      String? localPath,
      String? fullLocalPath,
      FileThumbnailsPlaceholder? placeholder,
      File? file,
      Vault? vault,
      void Function(BuildContext context, FileThumbnail state)? onPress,
      void Function(FileThumbnail state)? onLongPress,
      bool? isSelected,
      Map<String, dynamic>? data,
      bool? isGridView}) {
    return FileThumbnail(
        localPath: localPath ?? this.localPath,
        name: name ?? this.name,
        fullLocalPath: fullLocalPath ?? this.fullLocalPath,
        placeholder: placeholder ?? this.placeholder,
        file: file ?? this.file,
        vault: vault ?? this.vault,
        onPress: onPress ?? this.onPress,
        onLongPress: onLongPress ?? this.onLongPress,
        isSelected: isSelected ?? this.isSelected,
        data: data ?? this.data,
        isGridView: isGridView ?? this.isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return isGridView
        ? GridTile(
          child: Card(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            child: InkWell(
              onLongPress: () => onLongPress(this),
              onTap: () => onPress(context, this),
              borderRadius: BorderRadius.circular(15),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final textSpan = TextSpan(
                      text: name, style: DefaultTextStyle.of(context).style);
                  final textPainter = TextPainter(
                    text: textSpan,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                  );
                  textPainter.layout(
                      minWidth: constraints.minWidth,
                      maxWidth: constraints.maxWidth);

                  if (!textPainter.didExceedMaxLines) {
                    return Column(
                      children: [
                        placeholder.gridIcon,
                        Text(name),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        placeholder.gridIcon,
                        Expanded(
                          child: Marquee(
                              text: name,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 20,
                              fadingEdgeStartFraction: 1 / 2,
                              fadingEdgeEndFraction: 1 / 2,
                              showFadingOnlyWhenScrolling: false),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        )
        : ListTile(
            onTap: () => onPress(context, this),
            onLongPress: () => onLongPress(this),
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            title: Text(name),
            leading: placeholder.listIcon,
          );
  }
}
