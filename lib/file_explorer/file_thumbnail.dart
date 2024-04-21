import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/explorer_data.dart';
import 'package:marquee/marquee.dart';

/// Represents a [FileThumbnail] data-wise
class FileThumbnail extends StatelessWidget {
  final ThumbnailData data;

  const FileThumbnail(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    var state = ExplorerData.of(context).state;
    var placeholder = data.placeholder;

    return state.isGridView
        ? GridTile(
            child: Card.outlined(
              color: state.isSelected(data.localPath)
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: InkWell(
                onLongPress: () => state.onThumbnailLongTap(this),
                onTap: () => state.onThumbnailTap(context, this),
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final textSpan = TextSpan(
                        text: data.name,
                        style: DefaultTextStyle.of(context).style);
                    final textPainter = TextPainter(
                      text: textSpan,
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                    );
                    textPainter.layout(
                        minWidth: constraints.minWidth,
                        maxWidth: constraints.maxWidth);

                    if (!textPainter.didExceedMaxLines) {
                      return Column(children: [
                        placeholder.gridIcon,
                        Expanded(
                            child: Center(
                          child: Text(data.name),
                        ))
                      ]);
                    } else {
                      return Column(
                        children: [
                          placeholder.gridIcon,
                          Expanded(
                            child: Marquee(
                                text: data.name,
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
            onTap: () => state.onThumbnailTap(context, this),
            onLongPress: () => state.onThumbnailLongTap(this),
            tileColor: state.isSelected(data.localPath)
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            title: Text(data.name),
            leading: placeholder.listIcon,
          );
  }
}
