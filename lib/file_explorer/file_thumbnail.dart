import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/vault.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';

class FileThumbnail extends StatelessWidget {
  final String name;
  final String localPath;
  final FileThumbnailsPlaceholder placeholder;
  final File file;
  final Vault vault;
  final void Function(BuildContext context, FileThumbnail state) onPress;
  final void Function(FileThumbnail state) onLongPress;
  final bool isSelected;

  const FileThumbnail(
      {super.key,
        required this.localPath,
        required this.name,
        required this.placeholder,
        required this.file,
        required this.vault,
        required this.onPress,
        required this.onLongPress,
        required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: () => onLongPress(this),
        onTap: () => onPress(context, this),
        child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.tertiary.withOpacity(.3)
                      : Theme.of(context).colorScheme.outline.withOpacity(.1)),
              child: Column(children: [
                placeholder.icon,
                Text(name, overflow: TextOverflow.ellipsis)
              ]),
            )));
  }
}