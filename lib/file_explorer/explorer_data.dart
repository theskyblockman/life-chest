import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/file_placeholder.dart';
import 'package:life_chest/file_explorer/file_thumbnail.dart';
import 'package:life_chest/vault.dart';
import 'package:path/path.dart';

typedef ThumbnailTapCallback = void Function(
    BuildContext context, FileThumbnail thumbnail);
typedef ThumbnailLongTapCallback = void Function(FileThumbnail thumbnail);

typedef ExplorerState = ({
  ThumbnailTapCallback onThumbnailTap,
  ThumbnailLongTapCallback onThumbnailLongTap,
  Vault vault,
  bool isGridView,
  Set<String>? selectedThumbnails,
  List<ThumbnailData>? thumbnails,
  double? thumbnailSize,
});

extension ExplorerStateExtension on ExplorerState {
  ExplorerState copyWith(
      {ThumbnailTapCallback? onThumbnailTap,
      ThumbnailLongTapCallback? onThumbnailLongTap,
      Vault? vault,
      bool? isGridView,
      Set<String>? selectedThumbnails,
      List<ThumbnailData>? thumbnails,
      double? thumbnailSize}) {
    return (
      onThumbnailTap: onThumbnailTap ?? this.onThumbnailTap,
      onThumbnailLongTap: onThumbnailLongTap ?? this.onThumbnailLongTap,
      vault: vault ?? this.vault,
      isGridView: isGridView ?? this.isGridView,
      selectedThumbnails: selectedThumbnails ?? this.selectedThumbnails,
      thumbnails: thumbnails ?? this.thumbnails,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }

  bool isSelected(String localPath) =>
      selectedThumbnails?.contains(localPath) ?? false;
}

typedef ThumbnailData = MapEntry<String, dynamic>;

extension ThumbnailDataExtension on ThumbnailData {
  String get localPath => key;
  String get name => basename(value['name']);
  String get fullLocalPath => value['name'];
  FileThumbnailsPlaceholder get placeholder =>
      FileThumbnailsPlaceholder.getPlaceholderFromFileName(data);
  File getFile(Vault vault) => File(join(vault.path, basename(key)));
  Map<String, dynamic> get data => value;
}

class ExplorerData extends InheritedWidget {
  const ExplorerData({super.key, required super.child, required this.state});

  final ExplorerState state;

  static ExplorerData of(BuildContext context) {
    final ExplorerData? result =
        context.dependOnInheritedWidgetOfExactType<ExplorerData>();
    assert(result != null, 'No ExplorerData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ExplorerData oldWidget) {
    return state != oldWidget.state;
  }
}
