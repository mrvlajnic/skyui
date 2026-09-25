import 'package:flutter/foundation.dart';

enum VehicleState { parked, driving }

class DriveModeService {
  DriveModeService._();

  static final DriveModeService instance = DriveModeService._();

  final ValueNotifier<VehicleState> _state =
      ValueNotifier<VehicleState>(VehicleState.parked);

  ValueListenable<VehicleState> get state => _state;

  bool get isDriving => _state.value == VehicleState.driving;

  void update(VehicleState newState) {
    _state.value = newState;
  }

  void toggle() {
    if (!kDebugMode) return;
    update(isDriving ? VehicleState.parked : VehicleState.driving);
  }
}
