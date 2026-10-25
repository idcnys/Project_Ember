import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static bool isMuted = false;
  static bool isHapticEnabled = true;

  // BGM Track Constants
  static const String trackAmbient = "lexin_music-space-ambient-sci-fi-121842.mp3";
  static const String trackDetective = "atlasaudio-detective-518071.mp3";

  // SFX volume 50% by default, BGM ambient volume 40% by default
  static double sfxVolume = 0.5;
  static double bgmVolume = 0.4;
  static bool isBgmEnabled = true;
  static String currentTrack = trackAmbient;
  static bool _bgmStarted = false;
  static bool _initialized = false;

  // Global AudioContext configured for concurrent SFX & BGM playback
  // AndroidAudioFocus.none ensures SFX does not request exclusive audio focus,
  // preventing Android OS from pausing/stopping background music.
  static final AudioContext _audioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );

  // Dedicated players so rapid sounds (clicks, swipes, alerts, launches) don't violently clobber each other
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _swipePlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _launchPlayer = AudioPlayer();
  static final AudioPlayer _zoomPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  /// Initialize global audio engine & player contexts so BGM and SFX
  /// mix seamlessly without audio focus conflicts.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await AudioPlayer.global.setAudioContext(_audioContext);
      await Future.wait([
        _bgmPlayer.setAudioContext(_audioContext),
        _clickPlayer.setAudioContext(_audioContext),
        _swipePlayer.setAudioContext(_audioContext),
        _sfxPlayer.setAudioContext(_audioContext),
        _launchPlayer.setAudioContext(_audioContext),
        _zoomPlayer.setAudioContext(_audioContext),
      ]);

      // Guard against unexpected Android focus drops or background pause
      _bgmPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.paused &&
            _bgmStarted &&
            isBgmEnabled &&
            !isMuted) {
          _bgmPlayer.resume();
        }
      });

      // Loop insurance: re-trigger on completion if still active
      _bgmPlayer.onPlayerComplete.listen((_) {
        if (_bgmStarted && isBgmEnabled && !isMuted) {
          _bgmPlayer.play(AssetSource('sound/$currentTrack'));
        }
      });
    } catch (_) {
      // Gracefully silent in environments without audio device / tests
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Start ambient background music in loop with 40% volume by default
  static Future<void> startBgm({String? track}) async {
    await _ensureInitialized();
    if (track != null && track.isNotEmpty) {
      currentTrack = track;
    }
    if (!isBgmEnabled || isMuted) {
      return;
    }
    _bgmStarted = true;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(bgmVolume);
      await _bgmPlayer.play(
        AssetSource('sound/$currentTrack'),
      );
    } catch (_) {
      // Gracefully silent in environments without audio device / tests
    }
  }

  /// Switch the active BGM track dynamically
  static Future<void> setBgmTrack(String track) async {
    await _ensureInitialized();
    currentTrack = track;
    if (isBgmEnabled && !isMuted) {
      try {
        await _bgmPlayer.stop();
        await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgmPlayer.setVolume(bgmVolume);
        await _bgmPlayer.play(
          AssetSource('sound/$currentTrack'),
        );
        _bgmStarted = true;
      } catch (_) {}
    }
  }

  /// Turn BGM on or off
  static Future<void> setBgmEnabled(bool enabled) async {
    isBgmEnabled = enabled;
    try {
      if (!isBgmEnabled || isMuted) {
        _bgmStarted = false;
        await _bgmPlayer.stop();
      } else {
        await startBgm();
      }
    } catch (_) {}
  }

  /// Stop BGM
  static void stopBgm() {
    _bgmStarted = false;
    try {
      _bgmPlayer.stop();
    } catch (_) {}
  }

  /// Adjust BGM volume dynamically
  static void setBgmVolume(double volume) {
    bgmVolume = volume.clamp(0.0, 1.0);
    try {
      if (!isMuted && isBgmEnabled) {
        _bgmPlayer.setVolume(bgmVolume);
      }
    } catch (_) {}
  }

  /// Adjust SFX volume dynamically (50% default)
  static void setSfxVolume(double volume) {
    sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// Update mute status for both SFX and BGM
  static void updateMuted(bool muted) {
    isMuted = muted;
    try {
      if (isMuted) {
        _bgmPlayer.setVolume(0.0);
      } else {
        if (isBgmEnabled) {
          _bgmPlayer.setVolume(bgmVolume);
          if (!_bgmStarted) {
            startBgm();
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> _safePlay(AudioPlayer player, String soundFile) async {
    if (isMuted) return;
    try {
      await _ensureInitialized();
      await player.stop();
      await player.setVolume(sfxVolume);
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
