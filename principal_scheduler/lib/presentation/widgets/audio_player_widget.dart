import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/audio_provider.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String audioUrl;
  final String audioId;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.audioId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isCurrentAudio = audioProvider.currentAudioId == audioId;
        final isPlaying = isCurrentAudio && audioProvider.isPlaying;
        final isPaused = isCurrentAudio && audioProvider.isPaused;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Play/Pause Button and Progress
              Row(
                children: [
                  // Play/Pause Button
                  IconButton(
                    onPressed: () => _togglePlayback(context, audioProvider),
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Progress and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: isCurrentAudio ? audioProvider.progress : 0.0,
                            onChanged: isCurrentAudio
                                ? (value) => _seekTo(audioProvider, value)
                                : null,
                            activeColor: Theme.of(context).colorScheme.primary,
                            inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        
                        // Time Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCurrentAudio
                                  ? audioProvider.formatDuration(audioProvider.currentPosition)
                                  : '00:00',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              isCurrentAudio
                                  ? audioProvider.formatDuration(audioProvider.totalDuration)
                                  : '--:--',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Additional Controls
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop Button
                  IconButton(
                    onPressed: isCurrentAudio ? () => audioProvider.stopAudio() : null,
                    icon: const Icon(Icons.stop),
                    tooltip: 'Stop',
                  ),
                  
                  // Volume Control (simplified)
                  IconButton(
                    onPressed: () => _showVolumeDialog(context, audioProvider),
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Volume',
                  ),
                  
                  // Download/Share (placeholder)
                  IconButton(
                    onPressed: () => _showShareOptions(context),
                    icon: const Icon(Icons.share),
                    tooltip: 'Share',
                  ),
                ],
              ),
              
              // Loading Indicator
              if (audioProvider.isLoading && isCurrentAudio) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
              
              // Error Message
              if (audioProvider.errorMessage != null && isCurrentAudio) ...[
                const SizedBox(height: 8),
                Text(
                  audioProvider.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _togglePlayback(BuildContext context, AudioProvider audioProvider) {
    if (audioProvider.currentAudioId == audioId) {
      if (audioProvider.isPlaying) {
        audioProvider.pauseAudio();
      } else {
        audioProvider.playAudio(audioUrl, audioId);
      }
    } else {
      audioProvider.playAudio(audioUrl, audioId);
    }
  }

  void _seekTo(AudioProvider audioProvider, double value) {
    final duration = audioProvider.totalDuration;
    final position = Duration(milliseconds: (duration.inMilliseconds * value).round());
    audioProvider.seekTo(position);
  }

  void _showVolumeDialog(BuildContext context, AudioProvider audioProvider) {
    double volume = 1.0; // Default volume
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.volume_down),
                  Expanded(
                    child: Slider(
                      value: volume,
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                        });
                        audioProvider.setVolume(value);
                      },
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                  const Icon(Icons.volume_up),
                ],
              ),
              Text('${(volume * 100).round()}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                // Copy audio URL to clipboard
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                // Download audio file
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}