import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static bool isMuted = false;
  static bool isHapticEnabled = true;

  // Dedicated players so rapid sounds (clicks, swipes, alerts, launches) don't violently clobber each other
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _swipePlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _launchPlayer = AudioPlayer();
  static final AudioPlayer _zoomPlayer = AudioPlayer();

  static Future<void> _safePlay(AudioPlayer player, String soundFile) async {
    if (isMuted) return;
    try {
      await player.stop();
      await player.play(
        AssetSource('sound/$soundFile'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Gracefully silent in environments without audio device / tests
    }
  }

  /// Standard UI button click
  static void playClick() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
    _safePlay(_clickPlayer, 'click.wav');
  }

  /// Back navigation sound
  static void playBack() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
    _safePlay(_clickPlayer, 'on_back.wav');
  }

  /// Touch swipe transition across worlds / levels or unlocking
  static void playSwipe() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
    _safePlay(_swipePlayer, 'level_unlock.wav');
  }

  /// When level unlock occurs
  static void playLevelUnlock() {
    playSwipe();
  }

  /// Level card selection sound
  static void playCardSelect() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    _safePlay(_sfxPlayer, 'click.wav');
  }

  /// Level / Mission launch sound
  static void playLaunch() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    _safePlay(_launchPlayer, 'on_level_open.wav');
  }

  static void playLevelOpen() {
    playLaunch();
  }

  /// Level victory / puzzle solved sound
  static void playLevelComplete() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    _safePlay(_launchPlayer, 'level_complete.wav');
  }

  static void playSuccess() {
    playLevelComplete();
  }

  /// Full sector / world completed celebration
  static void playWorldComplete() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    _safePlay(_launchPlayer, 'world_complete.wav');
  }

  /// Clue / discovery notification chime
  static void playClueChime() {
    playLevelComplete();
  }

  /// Dialog hint / chat advance
  static void playHint() {
    playClick();
  }

  /// Alert sound
  static void playAlert() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    _safePlay(_sfxPlayer, 'click.wav');
  }

  /// Gear / Subsystem inspect toggle
  static void playGear() {
    playClick();
  }

  /// 3D camera zoom and reset control sound
  static void playZoom() {
    if (isHapticEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    _safePlay(_zoomPlayer, 'zoomin_ control.wav');
  }
}
