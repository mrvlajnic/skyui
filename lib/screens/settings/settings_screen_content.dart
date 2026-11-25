import 'package:flutter/material.dart';

import '../../core/app_version.dart';
import '../../core/theme/colors.dart';
import '../../services/simulation_settings.dart';

/// Full-screen settings panel.
///
/// Only the demo simulation controls exist so far; product settings are not
/// implemented. The panel is part of the prototype, not the shipped UI.
class SettingsScreenContent extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsScreenContent({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07090F),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _TopBar(onClose: onClose),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SimulationCard(),
                      SizedBox(height: 16),
                      _BuildStamp(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TopBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B10),
        border: Border(bottom: BorderSide(color: Color(0x18FFFFFF))),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Demo configuration',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Close settings',
            child: InkWell(
              key: const ValueKey('settings-close-button'),
              onTap: onClose,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  const _SimulationCard();

  static const List<double> _presets = [1, 5, 10, 20, 30, 60];

  @override
  Widget build(BuildContext context) {
    final settings = SimulationSettings.instance;
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final speed = settings.routeSpeed;
        final preview = settings.playbackDuration(const Duration(minutes: 15));
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111118),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'ROUTE SIMULATION',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEMO ONLY',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'How fast the simulated drive plays. This does not change the '
                'real navigation; it only makes a demo route watchable in '
                'seconds or in real time.',
                style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    _SpeedChip(
                      key: ValueKey('speed-preset-${preset.round()}'),
                      label: preset == 1
                          ? 'Real time'
                          : '${preset.round()}×',
                      selected: (speed - preset).abs() < 0.5,
                      onTap: () => settings.routeSpeed = preset,
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'Custom speed',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    settings.isRealTime
                        ? 'Real time'
                        : '${speed.round()}×',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withValues(alpha: 0.12),
                  trackHeight: 3,
                ),
                child: Slider(
                  key: const ValueKey('speed-slider'),
                  min: SimulationSettings.minSpeed,
                  max: SimulationSettings.maxSpeed,
                  divisions: 119,
                  value: speed,
                  onChanged: (value) =>
                      settings.routeSpeed = value.roundToDouble(),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.route_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        settings.isRealTime
                            ? 'A 15 min route plays in real time (15 min).'
                            : 'A 15 min route plays in '
                                  '${_formatDuration(preview)}.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('speed-reset'),
                      onPressed: settings.reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'The speed applies to the next route you start.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) return '${duration.inSeconds} s';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return seconds == 0 ? '$minutes min' : '$minutes min $seconds s';
  }
}

class _BuildStamp extends StatelessWidget {
  const _BuildStamp();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('build-stamp'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'SkyUI v${AppVersion.version}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'build ${AppVersion.buildStamp}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const Text(
            'If this timestamp is older than your latest build, the app did not '
            'refresh.',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SpeedChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.accent.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.65)
                  : const Color(0x22FFFFFF),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.accent : Colors.white70,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
