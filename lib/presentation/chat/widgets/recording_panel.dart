import 'package:flutter/material.dart';

class RecordingPanel extends StatelessWidget {
  final bool isRecording;
  final String? recordedFilePath;
  final bool isPlayingRecord;
  final int playPosition;
  final int recordDuration;
  final VoidCallback onDeleteRecord;
  final VoidCallback onStopRecordingAndSend;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPlayRecord;

  const RecordingPanel({
    super.key,
    required this.isRecording,
    this.recordedFilePath,
    required this.isPlayingRecord,
    required this.playPosition,
    required this.recordDuration,
    required this.onDeleteRecord,
    required this.onStopRecordingAndSend,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPlayRecord,
  });

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          if (isRecording || recordedFilePath != null) ...[
            Row(
              children: [
                Text(
                  isPlayingRecord
                      ? _formatDuration(playPosition)
                      : _formatDuration(recordDuration),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: recordDuration > 0
                        ? (isRecording
                            ? null
                            : (isPlayingRecord
                                ? playPosition / recordDuration
                                : 1.0))
                        : 0.0,
                    backgroundColor: Colors.white,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isRecording || recordedFilePath != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: onDeleteRecord,
                )
              else
                const SizedBox(width: 48),
              if (!isRecording && recordedFilePath != null)
                GestureDetector(
                  onTap: onStopRecordingAndSend,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    if (!isRecording) {
                      onStartRecording();
                    } else {
                      onStopRecordingAndSend();
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    child: Icon(
                      isRecording ? Icons.send : Icons.mic,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              if (recordedFilePath != null && !isRecording)
                IconButton(
                  icon: Icon(
                    isPlayingRecord ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: onPlayRecord,
                )
              else if (isRecording)
                IconButton(
                  icon: Icon(Icons.stop, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: onStopRecording,
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

