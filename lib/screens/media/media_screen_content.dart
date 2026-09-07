import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MediaTrack {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final int durationSeconds;

  const MediaTrack({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.durationSeconds,
  });
}

/// Automotive Music & Sound Experience for Veltron OS (SkyUI)
///
/// Designed to occupy Sections 1 & 2 of the 21:9 ultrawide cockpit layout,
/// leaving the Navigation Card anchored in Section 3 on the far right.
///
/// Features:
/// - Sources navigation (Veltron Sounds, Spotify, Radio DAB+, Bluetooth)
/// - Interactive track queue & library with live playing equalizer indicator
/// - Realistic spinning vinyl record visualizer with center Veltron badge
/// - Dynamic real-time audio spectrum waveform visualizer
/// - Full playback transport controls (Shuffle, Prev, Play/Pause, Next, Repeat)
/// - Interactive progress slider & sound stage selector (Meridian 3D, Driver Focus)
class MediaScreenContent extends StatefulWidget {
  final VoidCallback onClose;

  const MediaScreenContent({super.key, required this.onClose});

  @override
  State<MediaScreenContent> createState() => _MediaScreenContentState();
}

class _MediaScreenContentState extends State<MediaScreenContent>
    with TickerProviderStateMixin {
  int _selectedSourceIndex = 0;
  final List<String> _sources = const [
    'Veltron Sounds',
    'Spotify',
    'Radio DAB+',
    'Bluetooth',
  ];

  final List<MediaTrack> _queue = const [
    MediaTrack(
      title: 'Night Drive',
      artist: 'Veltron Sounds',
      album: 'Night Drive EP',
      duration: '05:00',
      durationSeconds: 300,
    ),
    MediaTrack(
      title: 'Cyber Sunset',
      artist: 'Synthwave Club',
      album: 'Neon Horizon',
      duration: '04:12',
      durationSeconds: 252,
    ),
    MediaTrack(
      title: 'Electric Velocity',
      artist: 'Veltron Sounds',
      album: 'Pure Electric LP',
      duration: '03:48',
      durationSeconds: 228,
    ),
    MediaTrack(
      title: 'Neon Rain',
      artist: 'Electro Aura',
      album: 'Midnight Tokyo',
      duration: '04:35',
      durationSeconds: 275,
    ),
    MediaTrack(
      title: 'Hyperdrive',
      artist: 'Pulse Matrix',
      album: 'Speedway 2026',
      duration: '03:22',
      durationSeconds: 202,
    ),
    MediaTrack(
      title: 'Midnight Cruise',
      artist: 'Veltron Sounds',
      album: 'Night Drive EP',
      duration: '04:50',
      durationSeconds: 290,
    ),
  ];

  int _currentTrackIndex = 0;
  bool _isPlaying = true;
  bool _isShuffle = false;
  int _repeatMode = 1; // 0: off, 1: all, 2: one
  int _soundStageIndex = 0; // 0: Meridian 3D, 1: Driver Focus, 2: All Cabin

  double _playbackPosition = 135.0; // in seconds (02:15)
  double _volumeLevel = 0.75;
  bool _isMuted = false;

  Timer? _playbackTimer;

  // Vinyl record rotation animation
  late final AnimationController _rotationController;

  // Equalizer spectrum waveform animation
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (_isPlaying) {
      _rotationController.repeat();
      _waveController.repeat();
    }

    _startPlaybackTimer();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          final maxDuration = _queue[_currentTrackIndex].durationSeconds.toDouble();
          if (_playbackPosition < maxDuration) {
            _playbackPosition += 1.0;
          } else {
            _playNext();
          }
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _rotationController.repeat();
        _waveController.repeat();
      } else {
        _rotationController.stop();
        _waveController.stop();
      }
    });
  }

  void _playNext() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _queue.length;
      _playbackPosition = 0.0;
    });
  }

  void _playPrevious() {
    setState(() {
      if (_playbackPosition > 5.0) {
        _playbackPosition = 0.0;
      } else {
        _currentTrackIndex =
            (_currentTrackIndex - 1 + _queue.length) % _queue.length;
        _playbackPosition = 0.0;
      }
    });
  }

  void _selectTrack(int index) {
    setState(() {
      _currentTrackIndex = index;
      _playbackPosition = 0.0;
      _isPlaying = true;
      _rotationController.repeat();
      _waveController.repeat();
    });
  }

  String _formatTime(double seconds) {
    final int sec = seconds.toInt();
    final int m = sec ~/ 60;
    final int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _queue[_currentTrackIndex];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left Card: Sources & Queue (Section 1) ───────────────────────────
        Expanded(
          flex: 10,
          child: _LibraryQueueCard(
            sources: _sources,
            selectedSourceIndex: _selectedSourceIndex,
            onSelectSource: (index) => setState(() => _selectedSourceIndex = index),
            queue: _queue,
            currentTrackIndex: _currentTrackIndex,
            isPlaying: _isPlaying,
            onSelectTrack: _selectTrack,
          ),
        ),

        const SizedBox(width: 20),

        // ── Right Card: Now Playing Stage (Section 2) ────────────────────────
        Expanded(
          flex: 12,
          child: _NowPlayingHeroCard(
            currentTrack: currentTrack,
            playbackPosition: _playbackPosition,
            isPlaying: _isPlaying,
            isShuffle: _isShuffle,
            repeatMode: _repeatMode,
            soundStageIndex: _soundStageIndex,
            volumeLevel: _volumeLevel,
            isMuted: _isMuted,
            rotationAnimation: _rotationController,
            waveAnimation: _waveController,
            formattedElapsed: _formatTime(_playbackPosition),
            onTogglePlay: _togglePlayPause,
            onNext: _playNext,
            onPrevious: _playPrevious,
            onToggleShuffle: () => setState(() => _isShuffle = !_isShuffle),
            onToggleRepeat: () => setState(() => _repeatMode = (_repeatMode + 1) % 3),
            onSeek: (val) => setState(() => _playbackPosition = val),
            onSelectSoundStage: (index) => setState(() => _soundStageIndex = index),
            onVolumeChange: (val) => setState(() {
              _volumeLevel = val;
              _isMuted = val == 0;
            }),
            onToggleMute: () => setState(() => _isMuted = !_isMuted),
            onClose: widget.onClose,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left Card: Sources & Queue
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryQueueCard extends StatelessWidget {
  final List<String> sources;
  final int selectedSourceIndex;
  final ValueChanged<int> onSelectSource;
  final List<MediaTrack> queue;
  final int currentTrackIndex;
  final bool isPlaying;
  final ValueChanged<int> onSelectTrack;

  const _LibraryQueueCard({
    required this.sources,
    required this.selectedSourceIndex,
    required this.onSelectSource,
    required this.queue,
    required this.currentTrackIndex,
    required this.isPlaying,
    required this.onSelectTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x22FFFFFF),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00C8FF).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFF00C8FF).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF00C8FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Media & Audio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Meridian Surround 3D · 14 Speakers',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Source Selection Chips ─────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sources.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = selectedSourceIndex == index;
                return GestureDetector(
                  onTap: () => onSelectSource(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D253D)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00A3FF).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sources[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Queue Header ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UP NEXT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${queue.length} Tracks',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Queue List ────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              itemCount: queue.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final track = queue[index];
                final isCurrent = currentTrackIndex == index;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectTrack(index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF16253B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF00A3FF).withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Index or Animated Equalizer
                          SizedBox(
                            width: 24,
                            child: isCurrent && isPlaying
                                ? const _MiniEqualizerIcon()
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? const Color(0xFF00A3FF)
                                          : Colors.white.withValues(alpha: 0.35),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 8),

                          // Track info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.artist,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Duration
                          Text(
                            track.duration,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right Card: Now Playing Hero Stage
// ─────────────────────────────────────────────────────────────────────────────

class _NowPlayingHeroCard extends StatelessWidget {
  final MediaTrack currentTrack;
  final double playbackPosition;
  final bool isPlaying;
  final bool isShuffle;
  final int repeatMode;
  final int soundStageIndex;
  final double volumeLevel;
  final bool isMuted;
  final AnimationController rotationAnimation;
  final AnimationController waveAnimation;
  final String formattedElapsed;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;
  final ValueChanged<double> onSeek;
  final ValueChanged<int> onSelectSoundStage;
  final ValueChanged<double> onVolumeChange;
  final VoidCallback onToggleMute;
  final VoidCallback onClose;

  const _NowPlayingHeroCard({
    required this.currentTrack,
    required this.playbackPosition,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.soundStageIndex,
    required this.volumeLevel,
    required this.isMuted,
    required this.rotationAnimation,
    required this.waveAnimation,
    required this.formattedElapsed,
    required this.onTogglePlay,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onSeek,
    required this.onSelectSoundStage,
    required this.onVolumeChange,
    required this.onToggleMute,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final maxDuration = currentTrack.durationSeconds.toDouble();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x22FFFFFF),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Bar: Audio Quality Badge + Close Button ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      color: Color(0xFF00C8FF),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FLAC 96kHz / 24-bit · Dolby Atmos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Close button ('X')
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Hero Section: Rotating Vinyl + Spectrum Bars ──────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spinning Vinyl Record
                Expanded(
                  flex: 5,
                  child: Center(
                    child: _RotatingVinylDisc(
                      animation: rotationAnimation,
                      albumLabel: currentTrack.title,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Track Details & Equalizer Waveform
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentTrack.artist}  ·  ${currentTrack.album}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 18),

                      // Spectrum Waveform Bars
                      _AudioSpectrumWaveform(
                        animation: waveAnimation,
                        isPlaying: isPlaying,
                      ),

                      const SizedBox(height: 16),

                      // Sound Stage Preset Chips
                      Row(
                        children: [
                          _SoundStageChip(
                            label: 'Meridian 3D',
                            isSelected: soundStageIndex == 0,
                            onTap: () => onSelectSoundStage(0),
                          ),
                          const SizedBox(width: 8),
                          _SoundStageChip(
                            label: 'Driver Focus',
                            isSelected: soundStageIndex == 1,
                            onTap: () => onSelectSoundStage(1),
                          ),
                          const SizedBox(width: 8),
                          _SoundStageChip(
                            label: 'All Seats',
                            isSelected: soundStageIndex == 2,
                            onTap: () => onSelectSoundStage(2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Timeline Progress Scrubber ─────────────────────────────────────
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: const Color(0xFF00C8FF),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: playbackPosition.clamp(0.0, maxDuration),
                  min: 0.0,
                  max: maxDuration,
                  onChanged: onSeek,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedElapsed,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      currentTrack.duration,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Bottom Controls: Transport + Volume ───────────────────────────
          Row(
            children: [
              // Transport Buttons
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shuffle button
                    IconButton(
                      onPressed: onToggleShuffle,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: isShuffle
                            ? const Color(0xFF00C8FF)
                            : Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Previous button
                    IconButton(
                      onPressed: onPrevious,
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Play / Pause glowing button
                    GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00C6FF),
                              Color(0xFF0072FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A3FF).withValues(alpha: 0.45),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Next button
                    IconButton(
                      onPressed: onNext,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Repeat button
                    IconButton(
                      onPressed: onToggleRepeat,
                      icon: Icon(
                        repeatMode == 2
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: repeatMode > 0
                            ? const Color(0xFF00C8FF)
                            : Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Volume slider with mute button
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggleMute,
                    child: Icon(
                      isMuted || volumeLevel == 0
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 4),
                        activeTrackColor: Colors.white70,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: isMuted ? 0.0 : volumeLevel,
                        min: 0.0,
                        max: 1.0,
                        onChanged: onVolumeChange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rotating Vinyl Record Component
// ─────────────────────────────────────────────────────────────────────────────

class _RotatingVinylDisc extends StatelessWidget {
  final AnimationController animation;
  final String albumLabel;

  const _RotatingVinylDisc({
    required this.animation,
    required this.albumLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * math.pi,
          child: child,
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0D0F14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFF00A3FF).withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vinyl grooves simulation
            CustomPaint(
              size: const Size(140, 140),
              painter: _VinylGroovesPainter(),
            ),

            // Center Label Disc
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF0072FF),
                    Color(0xFF002244),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.album_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            // Center spindle hole
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF07090F),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final groovePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double r = 32; r < 64; r += 5) {
      canvas.drawCircle(center, r, groovePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Spectrum Audio Waveform Bars
// ─────────────────────────────────────────────────────────────────────────────

class _AudioSpectrumWaveform extends StatelessWidget {
  final AnimationController animation;
  final bool isPlaying;

  const _AudioSpectrumWaveform({
    required this.animation,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;

        return SizedBox(
          height: 32,
          child: Row(
            children: List.generate(24, (index) {
              final wave = isPlaying
                  ? (math.sin(t * 2 * math.pi + index * 0.45).abs() * 0.75 + 0.25)
                  : 0.15;
              final barHeight = 6.0 + wave * 24.0;

              return Container(
                width: 3.5,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFF00C8FF).withValues(
                          alpha: (0.4 + (index / 24) * 0.6).clamp(0.0, 1.0))
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sound Stage Preset Chip
// ─────────────────────────────────────────────────────────────────────────────

class _SoundStageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundStageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D253D)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00A3FF).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00C8FF) : Colors.white60,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini Equalizer Icon in Track Row
// ─────────────────────────────────────────────────────────────────────────────

class _MiniEqualizerIcon extends StatelessWidget {
  const _MiniEqualizerIcon();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Bar(height: 12),
        const SizedBox(width: 2),
        _Bar(height: 16),
        const SizedBox(width: 2),
        _Bar(height: 9),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;

  const _Bar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF00A3FF),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
