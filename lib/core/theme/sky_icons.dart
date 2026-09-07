import 'package:phosphor_flutter/phosphor_flutter.dart';

/// SkyUI Icon Library
///
/// Sve ikonice u aplikaciji prolaze kroz ovu klasu.
/// Kasnije možemo zameniti Phosphor sa custom Veltron ikonama
/// bez menjanja ostatka projekta.

class SkyIcons {
  SkyIcons._();

  // Sidebar
  static final home = PhosphorIcons.houseSimple();
  static final navigation = PhosphorIcons.paperPlaneTilt();
  static final music = PhosphorIcons.musicNotesSimple();
  static final phone = PhosphorIcons.phone();
  static final vehicle = PhosphorIcons.carProfile();
  static final settings = PhosphorIcons.gearSix();

  // Vehicle
  static final battery = PhosphorIcons.batteryChargingVertical();
  static final charging = PhosphorIcons.lightning();
  static final range = PhosphorIcons.gauge();
  static final lock = PhosphorIcons.lockSimple();
  static final unlock = PhosphorIcons.lockSimpleOpen();

  // Climate
  static final climate = PhosphorIcons.fan();
  static final temperature = PhosphorIcons.thermometer();
  static final seat = PhosphorIcons.armchair();
  static final seatHeat = PhosphorIcons.fire();
  static final seatCool = PhosphorIcons.snowflake();

  // Media
  static final play = PhosphorIcons.play();
  static final pause = PhosphorIcons.pause();
  static final previous = PhosphorIcons.skipBack();
  static final next = PhosphorIcons.skipForward();
  static final volume = PhosphorIcons.speakerHigh();

  // Phone
  static final call = PhosphorIcons.phoneCall();
  static final message = PhosphorIcons.chatCircleText();

  // Search
  static final search = PhosphorIcons.magnifyingGlass();

  // Profile
  static final profile = PhosphorIcons.userCircle();

  // General
  static final more = PhosphorIcons.dotsThreeOutlineVertical();
  static final close = PhosphorIcons.x();
  static final back = PhosphorIcons.arrowLeft();
  static final forward = PhosphorIcons.arrowRight();

  // Status
  static final wifi = PhosphorIcons.wifiHigh();
  static final bluetooth = PhosphorIcons.bluetooth();
  static final signal = PhosphorIcons.cellSignalHigh();
  static final cloud = PhosphorIcons.cloud();

  // Navigation
  static final location = PhosphorIcons.mapPin();
  static final destination = PhosphorIcons.flagCheckered();
}