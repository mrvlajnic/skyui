import 'dart:async';
import 'package:flutter/material.dart';

/// Automotive Phone Screen for Veltron OS (SkyUI)
///
/// Implements a dual-card digital cockpit telephony hub:
/// - Left Card: Communication Hub (Dialer, sub-tabs, interactive keypad, recents list with letter avatars)
/// - Right Card: Connected Device Status (Xiaomi 17, smartphone silhouette, in-call HUD with controls)
class PhoneScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const PhoneScreen({super.key, this.onClose});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  int _selectedSubTab = 0; // 0: Dialer, 1: Recents, 2: Contacts, 3: Voicemail
  String _dialedNumber = '+381 63 123 4567';

  // Active call state
  bool _isInCall = true;
  bool _isMuted = false;
  int _callDurationSeconds = 24;
  Timer? _callTimer;

  // Active contact info
  String _activeCallerName = 'Helena (RS7)';
  String _activeCallerNumber = '+381 63 123 4567';
  String _activeCallerInitial = 'H';

  final List<_RecentCallItem> _recentCalls = const [
    _RecentCallItem(
      name: 'Aleksandar',
      initial: 'A',
      number: '+381 64 221 8899',
      type: _CallType.outgoing,
      typeLabel: 'Mobile',
      time: '10:32',
    ),
    _RecentCallItem(
      name: 'Helena (RS7)',
      initial: 'H',
      number: '+381 63 123 4567',
      type: _CallType.incoming,
      typeLabel: 'Mobile',
      time: '09:47',
    ),
    _RecentCallItem(
      name: 'Milan',
      initial: 'M',
      number: '+381 62 994 3321',
      type: _CallType.missed,
      typeLabel: 'Mobile',
      time: 'Yesterday',
    ),
    _RecentCallItem(
      name: 'Mama',
      initial: 'M',
      number: '+381 60 445 6789',
      type: _CallType.incoming,
      typeLabel: 'Mobile',
      time: 'Yesterday',
    ),
    _RecentCallItem(
      name: 'Petar',
      initial: 'P',
      number: '+381 65 778 1234',
      type: _CallType.incoming,
      typeLabel: 'Mobile',
      time: 'Mon',
    ),
    _RecentCallItem(
      name: 'VoIP Support',
      initial: 'V',
      number: '+381 11 300 0000',
      type: _CallType.work,
      typeLabel: 'Work',
      time: 'Mon',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isInCall && mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  void _onKeyPress(String value) {
    setState(() {
      _dialedNumber += value;
    });
  }

  void _onBackspace() {
    if (_dialedNumber.isNotEmpty) {
      setState(() {
        _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1);
      });
    }
  }

  void _onCallPressed() {
    if (_dialedNumber.trim().isEmpty) return;
    setState(() {
      _isInCall = true;
      _activeCallerName = _dialedNumber;
      _activeCallerNumber = _dialedNumber;
      _activeCallerInitial = _dialedNumber.replaceAll('+', '').isNotEmpty
          ? _dialedNumber.replaceAll('+', '')[0].toUpperCase()
          : 'P';
      _callDurationSeconds = 0;
    });
    _startCallTimer();
  }

  void _onEndCall() {
    setState(() {
      _isInCall = false;
    });
    _callTimer?.cancel();
  }

  void _selectContact(_RecentCallItem item) {
    setState(() {
      _dialedNumber = item.number;
      _activeCallerName = item.name;
      _activeCallerNumber = item.number;
      _activeCallerInitial = item.initial;
      _isInCall = true;
      _callDurationSeconds = 0;
    });
    _startCallTimer();
  }

  String _formatCallDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left Card: Communication Hub (Dialer & Recents) ──────────────
        Expanded(
          flex: 13,
          child: _LeftCommunicationCard(
            onClose: widget.onClose,
            selectedSubTab: _selectedSubTab,
            onSubTabChanged: (index) => setState(() => _selectedSubTab = index),
            dialedNumber: _dialedNumber,
            onKeyPress: _onKeyPress,
            onBackspace: _onBackspace,
            onCallPressed: _onCallPressed,
            recentCalls: _recentCalls,
            onSelectContact: _selectContact,
          ),
        ),

        const SizedBox(width: 20),

        // ── Right Card: Connected Device & In-Call HUD ───────────────────
        Expanded(
          flex: 8,
          child: _RightDeviceCard(
            isInCall: _isInCall,
            isMuted: _isMuted,
            callDuration: _formatCallDuration(_callDurationSeconds),
            callerName: _activeCallerName,
            callerNumber: _activeCallerNumber,
            callerInitial: _activeCallerInitial,
            onToggleMute: () => setState(() => _isMuted = !_isMuted),
            onEndCall: _onEndCall,
            onStartCall: _onCallPressed,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left Card: Communication Hub
// ─────────────────────────────────────────────────────────────────────────────

class _LeftCommunicationCard extends StatelessWidget {
  final VoidCallback? onClose;
  final int selectedSubTab;
  final ValueChanged<int> onSubTabChanged;
  final String dialedNumber;
  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onCallPressed;
  final List<_RecentCallItem> recentCalls;
  final ValueChanged<_RecentCallItem> onSelectContact;

  const _LeftCommunicationCard({
    this.onClose,
    required this.selectedSubTab,
    required this.onSubTabChanged,
    required this.dialedNumber,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onCallPressed,
    required this.recentCalls,
    required this.onSelectContact,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title & Subtitle ─────────────────────────────────────
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
                child: const Icon(
                  Icons.phone_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Connect · Call · Stay in touch',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
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
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Main Body: 3-column split ────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Sub-nav tabs
                SizedBox(
                  width: 135,
                  child: _SubNavTabs(
                    selectedIndex: selectedSubTab,
                    onTabSelected: onSubTabChanged,
                  ),
                ),

                const SizedBox(width: 16),

                // Subtle vertical divider
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),

                const SizedBox(width: 16),

                // 2. Dialer Keypad Center Section
                Expanded(
                  flex: 5,
                  child: _KeypadSection(
                    dialedNumber: dialedNumber,
                    onKeyPress: onKeyPress,
                    onBackspace: onBackspace,
                    onCallPressed: onCallPressed,
                  ),
                ),

                const SizedBox(width: 16),

                // Subtle vertical divider
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),

                const SizedBox(width: 16),

                // 3. Recent Calls List
                Expanded(
                  flex: 4,
                  child: _RecentsSection(
                    recentCalls: recentCalls,
                    onSelectContact: onSelectContact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub Navigation Tabs
// ─────────────────────────────────────────────────────────────────────────────

class _SubNavTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _SubNavTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dialpad_rounded, 'Dialer'),
      (Icons.access_time_rounded, 'Recent Calls'),
      (Icons.person_outline_rounded, 'Contacts'),
      (Icons.voicemail_rounded, 'Voicemail'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _SubNavItem(
            icon: items[i].$1,
            label: items[i].$2,
            selected: selectedIndex == i,
            onTap: () => onTabSelected(i),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SubNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF0D2338)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF00A3FF).withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF00A3FF)
                    : Colors.white.withValues(alpha: 0.45),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Keypad Section
// ─────────────────────────────────────────────────────────────────────────────

class _KeypadSection extends StatelessWidget {
  final String dialedNumber;
  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onCallPressed;

  const _KeypadSection({
    required this.dialedNumber,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ('1', ' '),
      ('2', 'ABC'),
      ('3', 'DEF'),
      ('4', 'GHI'),
      ('5', 'JKL'),
      ('6', 'MNO'),
      ('7', 'PQRS'),
      ('8', 'TUV'),
      ('9', 'WXYZ'),
      ('*', ''),
      ('0', '+'),
      ('#', ''),
    ];

    return Column(
      children: [
        // Number display bar
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dialedNumber.isEmpty ? 'Enter number' : dialedNumber,
                  style: TextStyle(
                    color: dialedNumber.isEmpty
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (dialedNumber.isNotEmpty)
                IconButton(
                  onPressed: onBackspace,
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Keypad grid + Call button
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3x4 Grid of keys
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int row = 0; row < 4; row++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int col = 0; col < 3; col++) ...[
                            _KeypadButton(
                              digit: keys[row * 3 + col].$1,
                              letters: keys[row * 3 + col].$2,
                              onTap: () => onKeyPress(keys[row * 3 + col].$1),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Glowing Call Button
              GestureDetector(
                onTap: onCallPressed,
                child: Container(
                  width: 54,
                  height: 54,
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
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String digit;
  final String letters;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.digit,
    required this.letters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Calls Section
// ─────────────────────────────────────────────────────────────────────────────

enum _CallType { incoming, outgoing, missed, work }

class _RecentCallItem {
  final String name;
  final String initial;
  final String number;
  final _CallType type;
  final String typeLabel;
  final String time;

  const _RecentCallItem({
    required this.name,
    required this.initial,
    required this.number,
    required this.type,
    required this.typeLabel,
    required this.time,
  });
}

class _RecentsSection extends StatelessWidget {
  final List<_RecentCallItem> recentCalls;
  final ValueChanged<_RecentCallItem> onSelectContact;

  const _RecentsSection({
    required this.recentCalls,
    required this.onSelectContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  'All',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.separated(
            itemCount: recentCalls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = recentCalls[index];
              return _RecentCallTile(
                item: item,
                onTap: () => onSelectContact(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentCallTile extends StatelessWidget {
  final _RecentCallItem item;
  final VoidCallback onTap;

  const _RecentCallTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData typeIcon;
    Color typeColor;

    switch (item.type) {
      case _CallType.incoming:
        typeIcon = Icons.call_received_rounded;
        typeColor = const Color(0xFF00E676);
        break;
      case _CallType.outgoing:
        typeIcon = Icons.call_made_rounded;
        typeColor = const Color(0xFF00A3FF);
        break;
      case _CallType.missed:
        typeIcon = Icons.call_missed_rounded;
        typeColor = const Color(0xFFFF5252);
        break;
      case _CallType.work:
        typeIcon = Icons.headset_mic_outlined;
        typeColor = Colors.white54;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              // Initial Letter Avatar (per user requirement)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E212D),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: item.type == _CallType.work
                      ? const Icon(Icons.headset_rounded, color: Colors.white70, size: 16)
                      : Text(
                          item.initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 10),

              // Name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(typeIcon, color: typeColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          item.typeLabel,
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
              ),

              // Time and chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right Card: Connected Device & In-Call HUD
// ─────────────────────────────────────────────────────────────────────────────

class _RightDeviceCard extends StatelessWidget {
  final bool isInCall;
  final bool isMuted;
  final String callDuration;
  final String callerName;
  final String callerNumber;
  final String callerInitial;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;
  final VoidCallback onStartCall;

  const _RightDeviceCard({
    required this.isInCall,
    required this.isMuted,
    required this.callDuration,
    required this.callerName,
    required this.callerNumber,
    required this.callerInitial,
    required this.onToggleMute,
    required this.onEndCall,
    required this.onStartCall,
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Device Status Bar ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A3FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF00A3FF).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.smartphone_rounded,
                      color: Color(0xFF00C8FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connected',
                        style: TextStyle(
                          color: Color(0xFF00C8FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Xiaomi 17',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Bluetooth',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Battery gauge
              Row(
                children: [
                  Text(
                    '78%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _BatteryIndicator(level: 0.78),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Main Body: Phone Silhouette & In-Call HUD ────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Smartphone Silhouette (Left)
                const Expanded(
                  flex: 5,
                  child: Center(
                    child: _SmartphoneSilhouette(),
                  ),
                ),

                const SizedBox(width: 16),

                // In-Call HUD (Right)
                Expanded(
                  flex: 6,
                  child: _InCallPanel(
                    isInCall: isInCall,
                    isMuted: isMuted,
                    callDuration: callDuration,
                    callerName: callerName,
                    callerNumber: callerNumber,
                    callerInitial: callerInitial,
                    onToggleMute: onToggleMute,
                    onEndCall: onEndCall,
                    onStartCall: onStartCall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Smartphone Silhouette Widget (Requested by user)
// ─────────────────────────────────────────────────────────────────────────────

class _SmartphoneSilhouette extends StatelessWidget {
  const _SmartphoneSilhouette();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF384052),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF00A3FF).withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
          color: const Color(0xFF06080E),
        ),
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Abstract Wallpaper Background with sleek blue curves
              CustomPaint(
                painter: _PhoneWallpaperPainter(),
              ),

              // Dynamic Island / Camera Notch at top
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 38,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF151922),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Lock Screen Time & Date
              Align(
                alignment: const Alignment(0.0, -0.35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '10:42',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tue, 27 May',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom home pill indicator
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneWallpaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deep dark blue radial base
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, 0.4),
        radius: 1.1,
        colors: [
          Color(0xFF002F5A),
          Color(0xFF030712),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Glowing cyan/blue organic waves
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.25);
    wavePath.cubicTo(
      size.width * 0.8,
      size.height * 0.35,
      size.width * 0.2,
      size.height * 0.75,
      size.width,
      size.height * 0.85,
    );
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00A3FF).withValues(alpha: 0.35),
          const Color(0xFF004488).withValues(alpha: 0.05),
        ],
      ).createShader(rect);
    canvas.drawPath(wavePath, wavePaint);

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.3);
    linePath.cubicTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width * 0.15,
      size.height * 0.7,
      size.width,
      size.height * 0.8,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// In-Call Status Panel
// ─────────────────────────────────────────────────────────────────────────────

class _InCallPanel extends StatelessWidget {
  final bool isInCall;
  final bool isMuted;
  final String callDuration;
  final String callerName;
  final String callerNumber;
  final String callerInitial;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;
  final VoidCallback onStartCall;

  const _InCallPanel({
    required this.isInCall,
    required this.isMuted,
    required this.callDuration,
    required this.callerName,
    required this.callerNumber,
    required this.callerInitial,
    required this.onToggleMute,
    required this.onEndCall,
    required this.onStartCall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Caller Avatar Circle with Silhouette / Letter (per user requirement)
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E212D),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: Colors.white70,
              size: 32,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Caller Name
        Text(
          callerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 3),

        // Caller details
        Text(
          'Mobile  $callerNumber',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Status indicator (Incoming call / Active call / Call ended)
        if (isInCall)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFF00E676),
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Incoming call',
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                callDuration,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Call ended',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // Action Buttons Row (Mute, Keypad, End / Call)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mute Button
            _ActionButton(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
              label: isMuted ? 'Muted' : 'Mute',
              active: isMuted,
              onTap: onToggleMute,
            ),

            const SizedBox(width: 12),

            // Keypad button
            _ActionButton(
              icon: Icons.dialpad_rounded,
              label: 'Keypad',
              active: false,
              onTap: () {},
            ),

            const SizedBox(width: 12),

            // End / Return Call button
            if (isInCall)
              _ActionButton(
                icon: Icons.call_end_rounded,
                label: 'End',
                isDestructive: true,
                onTap: onEndCall,
              )
            else
              _ActionButton(
                icon: Icons.phone_rounded,
                label: 'Call',
                isSuccess: true,
                onTap: onStartCall,
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isDestructive;
  final bool isSuccess;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.isDestructive = false,
    this.isSuccess = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    Color borderColor;

    if (isDestructive) {
      bgColor = const Color(0xFFD32F2F).withValues(alpha: 0.2);
      iconColor = const Color(0xFFFF5252);
      borderColor = const Color(0xFFD32F2F).withValues(alpha: 0.5);
    } else if (isSuccess) {
      bgColor = const Color(0xFF00E676).withValues(alpha: 0.2);
      iconColor = const Color(0xFF00E676);
      borderColor = const Color(0xFF00E676).withValues(alpha: 0.5);
    } else if (active) {
      bgColor = const Color(0xFF00A3FF).withValues(alpha: 0.2);
      iconColor = const Color(0xFF00A3FF);
      borderColor = const Color(0xFF00A3FF).withValues(alpha: 0.5);
    } else {
      bgColor = Colors.white.withValues(alpha: 0.04);
      iconColor = Colors.white.withValues(alpha: 0.85);
      borderColor = Colors.white.withValues(alpha: 0.08);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 54,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFFF5252)
                      : isSuccess
                          ? const Color(0xFF00E676)
                          : Colors.white.withValues(alpha: 0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final double level;

  const _BatteryIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 11,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Container(
            width: 18 * level,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
