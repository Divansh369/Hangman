import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final PocketBase pb = AuthService().pb;

  // Local preferences keys
  static const String _lastPlayDateKey = 'hangman_lastPlayDate';
  static const String _streakCountKey = 'hangman_streakCount';
  static const String _maxStreakKey = 'hangman_maxStreak';
  static const String _avatarKey = 'hangman_avatar';
  static const String _volumeKey = 'hangman_volume';
  static const String _hapticsKey = 'hangman_haptics';
  static const String _gamesPlayedKey = 'hangman_gamesPlayed';
  static const String _gamesWonKey = 'hangman_gamesWon';
  static const String _bestScoreKey = 'hangman_bestScore';

  Future<RecordModel?> _getRecordForUser(String userId) async {
    try {
      final list = await pb.collection('user_progress').getList(filter: 'user = "$userId"', perPage: 1);
      if (list.items.isNotEmpty) return list.items.first;
    } catch (e) {
      debugPrint('ProgressService._getRecordForUser error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getProgress() async {
    final user = AuthService().currentUser;
    if (user == null) {
      return null;
    }
    final rec = await _getRecordForUser(user.id);
    if (rec == null) {
      return null;
    }

    final levels = rec.getListValue('levelsCompleted');
    final collectibles = rec.getListValue('collectibles');
    final currency = rec.getIntValue('currency');

    return {
      'record': rec,
      'levelsCompleted': levels,
      'collectibles': collectibles,
      'currency': currency,
    };
  }

  Future<RecordModel> createProgressForUser(String userId) async {
    return await pb.collection('user_progress').create(body: {
      'user': userId,
      'levelsCompleted': [],
      'collectibles': [],
      'currency': 0,
    });
  }

  Future<RecordModel?> getOrCreateProgressRecord() async {
    final user = AuthService().currentUser;
    if (user == null) {
      return null;
    }
    final rec = await _getRecordForUser(user.id);
    if (rec != null) {
      return rec;
    }
    try {
      return await createProgressForUser(user.id);
    } catch (e) {
      debugPrint('createProgressForUser error: $e');
      return null;
    }
  }

  Future<bool> addCollectible(String collectibleId) async {
    final user = AuthService().currentUser;
    if (user == null) {
      return false;
    }
    try {
      final rec = await getOrCreateProgressRecord();
      if (rec == null) {
        return false;
      }
      final List current = rec.getListValue('collectibles');
      if (!current.contains(collectibleId)) {
        current.add(collectibleId);
      }
      await pb.collection('user_progress').update(rec.id, body: {'collectibles': current});
      return true;
    } catch (e) {
      debugPrint('addCollectible error: $e');
      return false;
    }
  }

  Future<bool> completeLevel(String levelId) async {
    final user = AuthService().currentUser;
    if (user == null) {
      return false;
    }
    try {
      final rec = await getOrCreateProgressRecord();
      if (rec == null) {
        return false;
      }
      final List current = rec.getListValue('levelsCompleted');
      if (!current.contains(levelId)) {
        current.add(levelId);
      }
      await pb.collection('user_progress').update(rec.id, body: {'levelsCompleted': current});
      return true;
    } catch (e) {
      debugPrint('completeLevel error: $e');
      return false;
    }
  }

  Future<bool> setCurrency(int value) async {
    final user = AuthService().currentUser;
    if (user == null) {
      return false;
    }
    try {
      final rec = await getOrCreateProgressRecord();
      if (rec == null) {
        return false;
      }
      await pb.collection('user_progress').update(rec.id, body: {'currency': value});
      return true;
    } catch (e) {
      debugPrint('setCurrency error: $e');
      return false;
    }
  }

  // Streak tracking methods (local)
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  Future<int> getMaxStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxStreakKey) ?? 0;
  }

  Future<void> updatePlayStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastPlayDateStr = prefs.getString(_lastPlayDateKey);
    
    int currentStreak = prefs.getInt(_streakCountKey) ?? 0;
    int maxStreak = prefs.getInt(_maxStreakKey) ?? 0;

    if (lastPlayDateStr == null) {
      // First play
      currentStreak = 1;
    } else {
      final lastPlayDate = DateTime.parse(lastPlayDateStr);
      final daysDiff = now.difference(lastPlayDate).inDays;
      
      if (daysDiff == 0) {
        // Same day, don't increment
      } else if (daysDiff == 1) {
        // Consecutive day, increment
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }

    // Update max streak if needed
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }

    // Store the updated values
    await prefs.setString(_lastPlayDateKey, now.toIso8601String());
    await prefs.setInt(_streakCountKey, currentStreak);
    await prefs.setInt(_maxStreakKey, maxStreak);
  }

  // Daily challenge seed generator (consistent across app restarts)
  String generateDailyChallengeSeed() {
    final now = DateTime.now();
    // Format: YYYYMMDD to ensure same seed for entire day
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  // Avatar management (local)
  static const List<String> avatarEmojis = [
    '😊', '🤓', '🎮', '🚀',
    '🌟', '👑', '🎨', '🏆'
  ];

  Future<String> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey) ?? avatarEmojis[0];
  }

  Future<void> setAvatar(String emoji) async {
    if (!avatarEmojis.contains(emoji)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, emoji);
  }

  // Volume management
  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value.clamp(0.0, 1.0));
  }

  // Haptics toggle
  Future<bool> isHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsKey) ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  // Game stats tracking
  Future<void> recordGameResult({required bool won, required int score}) async {
    final prefs = await SharedPreferences.getInstance();
    
    int played = prefs.getInt(_gamesPlayedKey) ?? 0;
    int wins = prefs.getInt(_gamesWonKey) ?? 0;
    int bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    
    played++;
    if (won) wins++;
    if (score > bestScore) bestScore = score;
    
    await prefs.setInt(_gamesPlayedKey, played);
    await prefs.setInt(_gamesWonKey, wins);
    await prefs.setInt(_bestScoreKey, bestScore);
  }

  Future<Map<String, int>> getGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'gamesPlayed': prefs.getInt(_gamesPlayedKey) ?? 0,
      'gamesWon': prefs.getInt(_gamesWonKey) ?? 0,
      'bestScore': prefs.getInt(_bestScoreKey) ?? 0,
      'streak': prefs.getInt(_streakCountKey) ?? 0,
      'maxStreak': prefs.getInt(_maxStreakKey) ?? 0,
    };
  }
}

