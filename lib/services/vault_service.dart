import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission_data.dart';
import '../models/campaign_data.dart';
import 'audio_service.dart';

class VaultService extends ChangeNotifier {
  static const String _keyUnlockedClues = "mohasunno_unlocked_clues";
  static const String _keyActiveMission = "mohasunno_active_mission";
  static const String _keySoundMuted = "mohasunno_sound_muted";
  static const String _keyHapticEnabled = "mohasunno_haptic_enabled";
  static const String _keyVolume = "mohasunno_volume";
  static const String _keyCompletedLevels = "mohasunno_completed_levels";
  static const String _keyLevelStars = "mohasunno_level_stars";
  static const String _keyActiveLevelId = "mohasunno_active_level_id";
  static const String _keyPlayerName = "ember_player_name";
  static const String _keyHasCompletedOnboarding = "ember_has_completed_onboarding";

  final List<MissionData> _missions = MissionsCatalog.getAllMissions();
  final List<CampaignWorld> _worlds = CampaignCatalog.getAllWorlds();

  String _activeMissionId = "mission-01";
  String _activeLevelId = "m1";
  String _playerName = "Commander Aohine";
  bool _hasCompletedOnboarding = false;
  bool _isSoundMuted = false;
  bool _isHapticEnabled = true;
  double _volume = 0.8;
  bool _isLoaded = false;

  List<MissionData> get missions => _missions;
  List<CampaignWorld> get worlds => _worlds;
  String get activeMissionId => _activeMissionId;
  String get activeLevelId => _activeLevelId;
  String get playerName => _playerName;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isSoundMuted => _isSoundMuted;
  bool get isHapticEnabled => _isHapticEnabled;
  double get volume => _volume;
  bool get isLoaded => _isLoaded;

  MissionData get currentMission {
    return _missions.firstWhere(
      (m) => m.id == _activeMissionId,
      orElse: () => _missions.first,
    );
  }

  CampaignLevel get activeLevel {
    for (var w in _worlds) {
      for (var l in w.levels) {
        if (l.id == _activeLevelId) return l;
      }
    }
    return _worlds.first.levels.first;
  }

  CampaignLevel? getLevelById(String levelId) {
    for (var w in _worlds) {
      for (var l in w.levels) {
        if (l.id == levelId) return l;
      }
    }
    return null;
  }

  int get totalCluesCount {
    return _missions.fold(0, (sum, m) => sum + m.clues.length);
  }

  int get unlockedCluesCount {
    return _missions.fold(0, (sum, m) => sum + m.unlockedCluesCount);
  }

  int get totalLevelsCount {
    return _worlds.fold(0, (sum, w) => sum + w.levels.length);
  }

  int get completedLevelsCount {
    return _worlds.fold(0, (sum, w) => sum + w.completedCount);
  }

  VaultService() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> unlockedIds = prefs.getStringList(_keyUnlockedClues) ?? [];
      final List<String> completedLevels = prefs.getStringList(_keyCompletedLevels) ?? [];
      final List<String> levelStarEntries = prefs.getStringList(_keyLevelStars) ?? [];

      _activeMissionId = prefs.getString(_keyActiveMission) ?? "mission-01";
      _activeLevelId = prefs.getString(_keyActiveLevelId) ?? "m1";
      _playerName = prefs.getString(_keyPlayerName) ?? "Commander Aohine";
      _hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
      _isSoundMuted = prefs.getBool(_keySoundMuted) ?? false;
      _isHapticEnabled = prefs.getBool(_keyHapticEnabled) ?? true;
      _volume = prefs.getDouble(_keyVolume) ?? 0.8;

      AudioService.isMuted = _isSoundMuted;
      AudioService.isHapticEnabled = _isHapticEnabled;

      // Restore clue state
      for (var mission in _missions) {
        for (var clue in mission.clues) {
          if (unlockedIds.contains(clue.id)) {
            clue.unlocked = true;
          }
        }
      }

      // Parse stars
      final Map<String, int> starMap = {};
      for (var entry in levelStarEntries) {
        final parts = entry.split(":");
        if (parts.length == 2) {
          starMap[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }

      // Restore campaign level state
      bool previousCompleted = true;
      for (var world in _worlds) {
        for (var level in world.levels) {
          if (completedLevels.contains(level.id)) {
            level.isCompleted = true;
            level.isUnlocked = true;
            level.stars = starMap[level.id] ?? 3;
            previousCompleted = true;
          } else if (previousCompleted || level.id == "m1") {
            level.isUnlocked = true;
            previousCompleted = false;
          } else {
            level.isUnlocked = false;
          }
        }
      }
    } catch (e) {
      debugPrint("Vault load error: $e");
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> completeCampaignLevel(String levelId, int stars) async {
    bool nextToUnlock = false;
    for (var world in _worlds) {
      for (int i = 0; i < world.levels.length; i++) {
        final level = world.levels[i];
        if (nextToUnlock) {
          level.isUnlocked = true;
          nextToUnlock = false;
        }
        if (level.id == levelId) {
          level.isCompleted = true;
          level.stars = stars.clamp(1, 3);
          nextToUnlock = true;
        }
      }
    }

    // Award clues associated with this level
    final prefix = levelId;
    await unlockClues(["$prefix-c01", "$prefix-c02", "$prefix-c03"]);

    await _saveState();
    notifyListeners();
  }

  void setActiveLevel(String levelId) {
    if (_activeLevelId != levelId) {
      _activeLevelId = levelId;
      _saveState();
      notifyListeners();
    }
  }

  Future<void> unlockClues(List<String> clueIds) async {
    bool changed = false;
    for (var mission in _missions) {
      for (var clue in mission.clues) {
        if (clueIds.contains(clue.id) && !clue.unlocked) {
          clue.unlocked = true;
          changed = true;
        }
      }
    }

    if (changed) {
      await _saveState();
      notifyListeners();
    }
  }

  void setActiveMission(String missionId) {
    if (_activeMissionId != missionId) {
      _activeMissionId = missionId;
      _saveState();
      notifyListeners();
    }
  }

  void setPlayerName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && trimmed != _playerName) {
      _playerName = trimmed;
      _saveState();
      notifyListeners();
    }
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _saveState();
    notifyListeners();
  }

  void resetOnboarding() {
    _hasCompletedOnboarding = false;
    _saveState();
    notifyListeners();
  }

  void toggleSound() {
    _isSoundMuted = !_isSoundMuted;
    AudioService.isMuted = _isSoundMuted;
    _saveState();
    notifyListeners();
  }

  void setSoundMuted(bool muted) {
    _isSoundMuted = muted;
    AudioService.isMuted = _isSoundMuted;
    _saveState();
    notifyListeners();
  }

  void toggleHaptics() {
    _isHapticEnabled = !_isHapticEnabled;
    AudioService.isHapticEnabled = _isHapticEnabled;
    _saveState();
    notifyListeners();
  }

  void setVolume(double val) {
    _volume = val;
    _saveState();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    for (var mission in _missions) {
      for (var clue in mission.clues) {
        clue.unlocked = false;
      }
    }
    for (var world in _worlds) {
      for (var level in world.levels) {
        level.isCompleted = false;
        level.stars = 0;
        level.isUnlocked = (level.id == "m1");
      }
    }
    _activeMissionId = "mission-01";
    _activeLevelId = "m1";
    await _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> unlockedIds = [];
      for (var mission in _missions) {
        for (var clue in mission.clues) {
          if (clue.unlocked) {
            unlockedIds.add(clue.id);
          }
        }
      }

      final List<String> completedLevels = [];
      final List<String> levelStarEntries = [];
      for (var world in _worlds) {
        for (var level in world.levels) {
          if (level.isCompleted) {
            completedLevels.add(level.id);
            levelStarEntries.add("${level.id}:${level.stars}");
          }
        }
      }

      await prefs.setStringList(_keyUnlockedClues, unlockedIds);
      await prefs.setStringList(_keyCompletedLevels, completedLevels);
      await prefs.setStringList(_keyLevelStars, levelStarEntries);
      await prefs.setString(_keyActiveMission, _activeMissionId);
      await prefs.setString(_keyActiveLevelId, _activeLevelId);
      await prefs.setString(_keyPlayerName, _playerName);
      await prefs.setBool(_keyHasCompletedOnboarding, _hasCompletedOnboarding);
      await prefs.setBool(_keySoundMuted, _isSoundMuted);
      await prefs.setBool(_keyHapticEnabled, _isHapticEnabled);
      await prefs.setDouble(_keyVolume, _volume);
    } catch (e) {
      debugPrint("Vault save error: $e");
    }
  }
}
