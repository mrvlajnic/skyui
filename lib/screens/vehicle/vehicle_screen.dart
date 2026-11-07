import 'package:flutter/material.dart';

import '../../services/drive_mode_service.dart';

/// Full-screen Vehicle module content (simulated telemetry demo).
///
/// Every value on this screen is fixture data and visually labelled DEMO.
/// The module is display-only in this slice: aside from the close affordance
/// there are no actuation controls, so no parked/driving policy statements
/// are required yet. The live drive state (Parked / Driving) is shown via
/// [DriveModeService] so the screen stays consistent with the header badge.
class VehicleScreenContent extends StatefulWidget {
  final VoidCallback onClose;

  const VehicleScreenContent({super.key, required this.onClose});

  @override
  State<VehicleScreenContent> createState() => _VehicleScreenContentState();
}

class _VehicleScreenContentState extends State<VehicleScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left card: Battery & Energy ─────────────────────────────────
        Expanded(
          flex: 6,
          child: _VehicleCard(
            icon: Icons.bolt_outlined,
            title: 'Energy',
            subtitle: 'Battery · Range · Efficiency',
            onClose: widget.onClose,
            closeKey: 'vehicle-close-button',
            closeLabel: 'Close vehicle',
            body: const _EnergyCardBody(),
          ),
        ),

        const SizedBox(width: 20),

        // ── Middle card: Tire pressure ──────────────────────────────────
        const Expanded(
          flex: 5,
          child: _VehicleCard(
            icon: Icons.tire_repair_outlined,
            title: 'Tire pressure',
            subtitle: 'Cold pressure · 2.4 bar nominal',
            body: _TirePressureCardBody(),
          ),
        ),

        const SizedBox(width: 20),

        // ── Right card: Drive modes & Service ───────────────────────────
        const Expanded(
          flex: 4,
          child: _VehicleCard(
            icon: Icons.build_circle_outlined,
            title: 'Service',
            subtitle: 'Modes · Maintenance',
            body: _ServiceCardBody(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card shell: header row + DEMO badge + optional close button
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onClose;
  final String? closeKey;
  final String? closeLabel;
  final Widget body;

  const _VehicleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    this.onClose,
    this.closeKey,
    this.closeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22FFFFFF), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: icon, title, DEMO badge, close ────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _DemoBadge(),
              if (onClose != null) ...[
                const SizedBox(width: 8),
                _CloseButton(
                  onClose: onClose!,
                  semanticsKey: closeKey,
                  label: closeLabel ?? 'Close',
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          Expanded(child: body),
        ],
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC857).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFC857).withValues(alpha: 0.5),
        ),
      ),
      child: const Text(
        'DEMO DATA',
        style: TextStyle(
          color: Color(0xFFFFC857),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;
  final String? semanticsKey;
  final String label;

  const _CloseButton({
    required this.onClose,
    this.semanticsKey,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: semanticsKey != null ? ValueKey(semanticsKey!) : null,
      button: true,
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Material(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 36,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small shared building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Parked / Driving chip driven by [DriveModeService].
class _DriveStateChip extends StatelessWidget {
  const _DriveStateChip();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VehicleState>(
      valueListenable: DriveModeService.instance.state,
      builder: (context, state, _) {
        final driving = state == VehicleState.driving;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: driving
                      ? const Color(0xFF00A3FF)
                      : const Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                driving ? 'DRIVING' : 'PARKED',
                style: TextStyle(
                  color: driving
                      ? const Color(0xFF00A3FF)
                      : const Color(0xFF00E676),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left card: Battery & Energy
// ─────────────────────────────────────────────────────────────────────────────

class _EnergyCardBody extends StatelessWidget {
  const _EnergyCardBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drive state row
        const Row(children: [_DriveStateChip()]),

        const SizedBox(height: 16),

        // ── Hero: SoC + estimated range ──────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('BATTERY'),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        '76',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('ESTIMATED RANGE'),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        '385',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'km',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Battery level bar (fixture-consistent with the compact card) ──
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.76,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Trip stats (fixture-consistent with the climate strip) ──────
        const Row(
          children: [
            Expanded(
              child: _StatBlock(value: '16.4', label: 'KWH/100 KM'),
            ),
            Expanded(
              child: _StatBlock(value: '+3.2 kWh', label: 'REGENERATED'),
            ),
            Expanded(
              child: _StatBlock(value: '14.0%', label: 'TRIP EFFICIENCY'),
            ),
          ],
        ),

        const Spacer(),

        // ── Charging state (display-only, as parked policy requires) ────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.power_off_outlined,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                'Not plugged in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Charging controls unavailable in prototype',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Middle card: Tire pressure
// ─────────────────────────────────────────────────────────────────────────────

class _TireTile extends StatelessWidget {
  final String position;
  final String pressure;

  const _TireTile({required this.position, required this.pressure});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  position,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              pressure,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Optimal · 32°C',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TirePressureCardBody extends StatelessWidget {
  const _TirePressureCardBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Schematic: front wheels, car outline, rear wheels ───────────
        Row(
          children: const [
            _TireTile(position: 'FL', pressure: '2.4 bar'),
            SizedBox(width: 12),
            _TireTile(position: 'FR', pressure: '2.4 bar'),
          ],
        ),

        const SizedBox(height: 12),

        // Car outline between wheel rows
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car_outlined,
                color: Colors.white.withValues(alpha: 0.25),
                size: 40,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: const [
            _TireTile(position: 'RL', pressure: '2.5 bar'),
            SizedBox(width: 12),
            _TireTile(position: 'RR', pressure: '2.5 bar'),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'All tires nominal · Last checked 2 days ago (demo)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right card: Drive modes & Service
// ─────────────────────────────────────────────────────────────────────────────

class _ModeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCurrent;

  const _ModeRow({
    required this.icon,
    required this.label,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label — mode switching unavailable in prototype',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFF00A3FF).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isCurrent
                  ? const Color(0xFF00A3FF)
                  : Colors.white.withValues(alpha: 0.35),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isCurrent
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isCurrent)
              Text(
                'ACTIVE',
                style: TextStyle(
                  color: const Color(0xFF00A3FF).withValues(alpha: 0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCardBody extends StatelessWidget {
  const _ServiceCardBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Drive modes (display-only) ──────────────────────────────────
        const _SectionLabel('DRIVE MODE'),
        const SizedBox(height: 10),
        const _ModeRow(
          icon: Icons.eco_outlined,
          label: 'Comfort',
          isCurrent: true,
        ),
        const _ModeRow(
          icon: Icons.speed_outlined,
          label: 'Sport',
          isCurrent: false,
        ),
        const _ModeRow(
          icon: Icons.energy_savings_leaf_outlined,
          label: 'Eco',
          isCurrent: false,
        ),
        const _ModeRow(
          icon: Icons.tune_outlined,
          label: 'Individual',
          isCurrent: false,
        ),

        const SizedBox(height: 12),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
        const SizedBox(height: 12),

        // ── Service snapshot ────────────────────────────────────────────
        Row(
          children: const [
            Expanded(
              child: _StatBlock(value: '3,400 km', label: 'TO SERVICE'),
            ),
            Expanded(
              child: _StatBlock(value: '84 days', label: 'REMAINING'),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Text(
                'Odometer 12,480 km',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF00E676),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'All systems OK',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
