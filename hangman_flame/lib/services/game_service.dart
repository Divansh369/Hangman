import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:math';
import 'dart:async';
import 'auth_service.dart';

class GameService {
  final PocketBase pb = AuthService().pb;

  Future<RecordModel> createRoom() async {
    final String code = _generateRoomCode();
    final currentUser = AuthService().currentUser;

    return await pb.collection('rooms').create(body: {
      'code': code,
      'host': currentUser?.id,
      'status': 'waiting',
      'guessedLetters': [],
      'wrongGuesses': 0,
    });
  }

  Future<RecordModel?> joinRoom(String code) async {
    try {
      final rooms = await pb.collection('rooms').getList(
        filter: 'code = "$code" && status = "waiting"',
      );

      if (rooms.items.isNotEmpty) {
        final room = rooms.items.first;
        final currentUser = AuthService().currentUser;

        return await pb.collection('rooms').update(room.id, body: {
          'opponent': currentUser?.id,
          'status': 'playing',
          'turn': room.getStringValue('host'),
        });
      }
    } catch (e) {
      debugPrint('Join room error: $e');
    }
    return null;
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await pb.collection('rooms').update(roomId, body: data);
  }

  Stream<RecordModel> subscribeToRoom(String roomId) {
    final controller = StreamController<RecordModel>();
    
    pb.collection('rooms').subscribe(roomId, (e) {
      if (e.record != null) {
        controller.add(e.record!);
      }
    }).then((unsubscribe) {
      controller.onCancel = () {
        unsubscribe();
        controller.close();
      };
    });

    return controller.stream;
  }

  Future<void> sendMessage(String roomId, String text) async {
    final currentUser = AuthService().currentUser;
    await pb.collection('messages').create(body: {
      'room': roomId,
      'user': currentUser?.id,
      'text': text,
    });
  }

  Stream<RecordModel> subscribeToChat(String roomId) {
    final controller = StreamController<RecordModel>();
    pb.collection('messages').subscribe('*', (e) {
      if (e.record != null && e.record!.getStringValue('room') == roomId) {
        controller.add(e.record!);
      }
    }).then((unsubscribe) {
      controller.onCancel = () {
        unsubscribe();
        controller.close();
      };
    });
    return controller.stream;
  }

  String _generateRoomCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  Future<List<RecordModel>> getLeaderboard() async {
    final result = await pb.collection('users').getList(
      sort: '-score',
      perPage: 10,
    );
    return result.items;
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      final room = await pb.collection('rooms').getOne(roomId);
      final currentUser = AuthService().currentUser?.id;
      if (currentUser == null) {
        return;
      }

      final host = room.getStringValue('host');
      final opponent = room.getStringValue('opponent');

      if (currentUser == host) {
        // Host leaving: mark room ended so others see it finished
        await pb.collection('rooms').update(roomId, body: {'status': 'ended'});
      } else if (currentUser == opponent) {
        // Opponent leaving: clear opponent and set status back to waiting
        await pb.collection('rooms').update(roomId, body: {'opponent': null, 'status': 'waiting'});
      }
    } catch (e) {
      debugPrint('leaveRoom error: $e');
    }
  }

  Future<RecordModel?> resyncRoom(String roomId) async {
    try {
      return await pb.collection('rooms').getOne(roomId);
    } catch (e) {
      debugPrint('resyncRoom error: $e');
      return null;
    }
  }

  Future<RecordModel?> findActiveRoomForUser(String userId) async {
    try {
      final list = await pb.collection('rooms').getList(filter: 'host = "$userId" || opponent = "$userId"');
      if (list.items.isNotEmpty) {
        return list.items.first;
      }
    } catch (e) {
      debugPrint('findActiveRoomForUser error: $e');
    }
    return null;
  }
}
