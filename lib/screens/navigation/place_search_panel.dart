import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/place.dart';
import '../../services/geocoding_service.dart';

enum SearchTarget { start, destination }

/// Compact place search used by the expanded Navigation module.
///
/// Search results come from the provider; the vehicle position and the route
/// remain simulated until routing and positioning exist.
class PlaceSearchPanel extends StatefulWidget {
  final GeocodingService? service;
  final String unavailableReason;
  final Place? initialStart;
  final Place? initialDestination;
  final void Function(SearchTarget target, Place place) onPlaceSelected;
  final VoidCallback onClose;

  const PlaceSearchPanel({
    super.key,
    required this.service,
    required this.unavailableReason,
    required this.onPlaceSelected,
    required this.onClose,
    this.initialStart,
    this.initialDestination,
  });

  @override
  State<PlaceSearchPanel> createState() => _PlaceSearchPanelState();
}

class _PlaceSearchPanelState extends State<PlaceSearchPanel> {
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  late final TextEditingController _startController;
  late final TextEditingController _destinationController;
  final FocusNode _destinationFocus = FocusNode();

  SearchTarget _active = SearchTarget.destination;
  Timer? _debounce;
  int _requestId = 0;
  bool _loading = false;
  String? _error;
  List<Place> _results = const [];

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: widget.initialStart?.name ?? '',
    );
    _destinationController = TextEditingController(
      text: widget.initialDestination?.name ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _startController.dispose();
    _destinationController.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  void _onChanged(SearchTarget target, String value) {
    setState(() => _active = target);
    _debounce?.cancel();

    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(_debounceDelay, () => _runSearch(query, target));
  }

  Future<void> _runSearch(String query, SearchTarget target) async {
    final service = widget.service;
    if (service == null) {
      setState(() => _error = widget.unavailableReason);
      return;
    }

    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final places = await service.search(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = places;
        _loading = false;
      });
    } on GeocodingException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error.message;
        _loading = false;
        _results = const [];
      });
    }
  }

  void _select(Place place) {
    widget.onPlaceSelected(_active, place);
    if (_active == SearchTarget.destination) {
      widget.onClose();
      return;
    }
    setState(() => _active = SearchTarget.destination);
    _destinationFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final serviceAvailable = widget.service != null;

    return Material(
      color: Colors.transparent,
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
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Plan a route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('place-search-close'),
                  onPressed: widget.onClose,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Close search',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _field(
              target: SearchTarget.start,
              controller: _startController,
              icon: Icons.trip_origin,
              iconColor: const Color(0xFF00E676),
              hint: 'Current location (simulated)',
              fieldKey: const ValueKey('place-search-start'),
              enabled: serviceAvailable,
            ),
            const SizedBox(height: 8),
            _field(
              target: SearchTarget.destination,
              controller: _destinationController,
              icon: Icons.place_outlined,
              iconColor: const Color(0xFFFF8A00),
              hint: 'Destination',
              fieldKey: const ValueKey('place-search-destination'),
              focusNode: _destinationFocus,
              enabled: serviceAvailable,
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Expanded(
              child: serviceAvailable
                  ? _resultsView()
                  : _message(widget.unavailableReason),
            ),
            const SizedBox(height: 6),
            Text(
              'Search by MapTiler · vehicle position simulated',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
                fontSize: 9.5,
                letterSpacing: 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required SearchTarget target,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required Key fieldKey,
    required bool enabled,
    FocusNode? focusNode,
  }) {
    final isActive = _active == target;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00A3FF).withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              cursorColor: const Color(0xFF00A3FF),
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                ),
              ),
              onTap: () => setState(() => _active = target),
              onChanged: (value) => _onChanged(target, value),
              onSubmitted: (value) => _runSearch(value, target),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsView() {
    if (_error != null) {
      return _message(_error!);
    }
    if (_results.isEmpty) {
      return _message('Type at least 3 characters to search.');
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final place = _results[index];
        return InkWell(
          key: ValueKey('place-result-${place.id}'),
          onTap: () => _select(place),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  place.address,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _message(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
