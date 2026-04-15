import 'dart:async';

// Universal debouncer for various operations
class Debouncer {
  Timer? _timer;
  final Duration duration;
  final Function action;

  Debouncer({required this.duration, required this.action});

  void call() {
    _timer?.cancel();
    _timer = Timer(duration, () {
      action();
    });
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Cache layer with TTL (time-to-live) support
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({required this.value, required this.ttl}) 
    : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

class Cache<K, V> {
  final Map<K, CacheEntry<V>> _entries = {};
  final Duration defaultTtl;

  Cache({this.defaultTtl = const Duration(minutes: 5)});

  void set(K key, V value, {Duration? ttl}) {
    _entries[key] = CacheEntry(value: value, ttl: ttl ?? defaultTtl);
  }

  V? get(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    return entry.value;
  }

  bool has(K key) => get(key) != null;

  void invalidate(K key) => _entries.remove(key);

  void clear() => _entries.clear();
}
