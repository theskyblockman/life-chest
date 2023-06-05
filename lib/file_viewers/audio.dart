import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/file_recovery/single_threaded_recovery.dart';
import 'package:life_chest/file_viewers/file_viewer.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {},
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: value,
            onChanged: (value) {
              if (!_dragging) {
                _dragging = true;
              }
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragging = false;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class AudioListener extends FileViewer {
  EncryptedAudioSource? audioSource;
  final AudioPlayer player = AudioPlayer();
  static late final AudioPlayerHandler audioHandler;

  AudioListener(
      {required super.fileVault,
      required super.fileToRead,
      required super.fileName,
      required super.fileData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show media item title
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;
              return Column(
                children: [
                  mediaItem?.artHeaders != null &&
                          mediaItem?.artHeaders!['artData'] != null
                      ? Column(
                          children: [
                            Image.memory(base64Decode(
                                mediaItem!.artHeaders!['artData']!)),
                            const Padding(padding: EdgeInsets.only(top: 15))
                          ],
                        )
                      : Container(),
                  Text(mediaItem?.title ?? p.basenameWithoutExtension(fileName),
                      textAlign: TextAlign.center),
                  const Padding(padding: EdgeInsets.only(top: 15))
                ],
              );
            },
          ),
          // Play/pause/stop buttons.
          StreamBuilder<bool>(
            stream: audioHandler.playbackState
                .map((state) => state.playing)
                .distinct(),
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _button(context, Icons.replay_10, audioHandler.rewind),
                  if (playing)
                    _button(context, Icons.pause, audioHandler.pause)
                  else
                    _button(context, Icons.play_arrow, audioHandler.play),
                  _button(context, Icons.forward_10, audioHandler.fastForward),
                ],
              );
            },
          ),
          // A seek bar.
          StreamBuilder<MediaState>(
            stream: _mediaStateStream,
            builder: (context, snapshot) {
              final mediaState = snapshot.data;
              return SeekBar(
                duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                position: mediaState?.position ?? Duration.zero,
                onChangeEnd: (newPosition) {
                  audioHandler.seek(newPosition);
                },
              );
            },
          ),
          // Display the processing state.
          StreamBuilder<AudioProcessingState>(
            stream: audioHandler.playbackState
                .map((state) => state.processingState)
                .distinct(),
            builder: (context, snapshot) {
              final processingState =
                  snapshot.data ?? AudioProcessingState.idle;
              return Text("Processing state: ${describeEnum(processingState)}");
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<bool> load() async {
    return true;
  }

  @override
  void dispose() {
    audioHandler.stop();
  }

  @override
  String loadingMessage(BuildContext context) =>
      S.of(context).loadingAudioTrack;

  @override
  bool extendBody() => true;

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
              audioHandler.mediaItem,
              AudioService.position,
              (mediaItem, position) => MediaState(mediaItem, position))
          .asBroadcastStream();

  IconButton _button(
          BuildContext context, IconData iconData, VoidCallback onPressed) =>
      IconButton(
        icon: Icon(iconData),
        iconSize: 48.0,
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith((states) {
              return Theme.of(context).colorScheme.onTertiary;
            }),
            iconColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).colorScheme.onTertiaryContainer)),
      );

  @override
  Future<void> onFocus() async {
    audioSource ??= EncryptedAudioSource(
        fileToRead,
        fileVault.encryptionKey!,
        fileData['audioData']['mimeType'],
        fileToRead.statSync().size);
    Metadata parsedMetadata = Metadata(
        trackName: fileData['audioData']['trackName'],
        trackArtistNames: fileData['audioData']['trackArtistNames'] != null
            ? List<String>.from(fileData['audioData']['trackArtistNames'])
            : null,
        albumName: fileData['audioData']['albumName'],
        albumArtistName: fileData['audioData']['albumArtistName'],
        trackNumber: fileData['audioData']['trackNumber'],
        albumLength: fileData['audioData']['albumLength'],
        year: fileData['audioData']['year'],
        genre: fileData['audioData']['genre'],
        authorName: fileData['audioData']['authorName'],
        writerName: fileData['audioData']['writerName'],
        discNumber: fileData['audioData']['discNumber'] != null
            ? int.parse(fileData['audioData']['discNumber'])
            : null,
        mimeType: fileData['audioData']['mimeType'],
        trackDuration: fileData['audioData']['trackDuration'],
        bitrate: fileData['audioData']['bitrate']);
    audioHandler.playFile(
        MediaItem(
            id: fileName,
            title: parsedMetadata.trackName ?? p.basename(fileName),
            album: parsedMetadata.albumName,
            artist: parsedMetadata.authorName,
            duration: parsedMetadata.trackDuration != null
                ? Duration(milliseconds: parsedMetadata.trackDuration!)
                : null,
            displayTitle: parsedMetadata.trackName,
            displayDescription: parsedMetadata.albumName,
            displaySubtitle: parsedMetadata.year?.toString(),
            artHeaders: fileData['audioData']['trackCover'] != null
                ? {'artData': fileData['audioData']['trackCover']}
                : null),
        audioSource!);
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class EncryptedAudioSource extends StreamAudioSource {
  List<int> bufferedData = [];
  Completer? targetCompleter;
  int? currentTarget;
  final String mimeType;
  final int fileByteLength;
  final File fileToRead;
  final SecretKey encryptionKey;

  EncryptedAudioSource(
      this.fileToRead, this.encryptionKey, this.mimeType, this.fileByteLength);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= fileByteLength;

    return StreamAudioResponse(
        sourceLength: fileByteLength,
        contentLength: end - start,
        offset: start,
        stream: await SingleThreadedRecovery.loadAndDecryptPartialFile(
            encryptionKey, fileToRead, start, end),
        contentType: mimeType,
        rangeRequestsSupported: true);
  }
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void playFile(MediaItem item, EncryptedAudioSource source) {
    mediaItem.add(item);
    _player.setAudioSource(source);
  }

  @override
  Future<void> play() async {
    if (playbackState.value.processingState == AudioProcessingState.ready) {
      _player.play();
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
