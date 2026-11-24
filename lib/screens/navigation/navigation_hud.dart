import 'package:flutter/material.dart';

/// Turn-by-turn banner shown while a route is active.
///
/// Instructions come from the routing provider; the distance, remaining time
/// and vehicle position are simulated on desktop.
class NavigationGuidanceBanner extends StatelessWidget {
  final IconData icon;
  final String instruction;
  final String distanceLabel;
  final String remainingLabel;
  final bool arrived;
  final VoidCallback onEnd;

  const NavigationGuidanceBanner({
    super.key,
    required this.icon,
    required this.instruction,
    required this.distanceLabel,
    required this.remainingLabel,
    required this.onEnd,
    this.arrived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$instruction, $distanceLabel, $remainingLabel',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF013131A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    (arrived
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF8A00))
                        .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: arrived
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFF8A00),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distanceLabel,
                    style: TextStyle(
                      color: arrived
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF8A00),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    remainingLabel,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              key: const ValueKey('guidance-end-button'),
              onPressed: onEnd,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white54,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(48, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'End',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps a provider maneuver type to a Material icon.
IconData maneuverIconFor(String type) {
  switch (type) {
    case 'leftTurn':
      return Icons.turn_left_rounded;
    case 'rightTurn':
      return Icons.turn_right_rounded;
    case 'slightLeftTurn':
      return Icons.turn_slight_left_rounded;
    case 'slightRightTurn':
      return Icons.turn_slight_right_rounded;
    case 'sharpLeftTurn':
      return Icons.turn_sharp_left_rounded;
    case 'sharpRightTurn':
      return Icons.turn_sharp_right_rounded;
    case 'roundaboutEnter':
    case 'roundaboutExit':
      return Icons.roundabout_left_rounded;
    case 'merge':
      return Icons.merge_rounded;
    case 'fork':
      return Icons.fork_left_rounded;
    case 'ramp':
      return Icons.ramp_right_rounded;
    case 'destination':
      return Icons.flag_rounded;
    case 'start':
      return Icons.navigation_rounded;
    default:
      return Icons.straight_rounded;
  }
}
