import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom {
  final String id;
  final String name;
  final String type; // 'package' or 'topic'
  final String? description;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    this.description,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) => ChatRoom(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        description: map['description'] as String?,
      );
}

class ChatMessage {
  final String id;
  final String roomId;
  final String userId;
  final String userEmail;
  final String content;
  final bool isAi;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userEmail,
    required this.content,
    required this.isAi,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        roomId: map['room_id'] as String,
        userId: map['user_id'] as String,
        userEmail: map['user_email'] as String? ?? 'anonymous',
        content: map['content'] as String,
        isAi: map['is_ai'] as bool? ?? false,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ChatService {
  final _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ── Rooms ─────────────────────────────────────────────────────────────────

  Future<List<ChatRoom>> getRooms() async {
    final data = await _supabase
        .from('chat_rooms')
        .select()
        .order('type')
        .order('name');
    return (data as List).map((e) => ChatRoom.fromMap(e)).toList();
  }

  Future<ChatRoom> createRoom({
    required String name,
    required String type,
    String? description,
  }) async {
    final data = await _supabase
        .from('chat_rooms')
        .insert({'name': name, 'type': type, 'description': description})
        .select()
        .single();
    return ChatRoom.fromMap(data);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final data = await _supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (data as List).map((e) => ChatMessage.fromMap(e)).toList();
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
    bool isAi = false,
    String? aiEmail,
  }) async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('chat_messages').insert({
      'room_id': roomId,
      'user_id': isAi ? 'ai-assistant' : (user?.id ?? 'anonymous'),
      'user_email': isAi ? (aiEmail ?? 'AI Assistant') : (user?.email ?? 'anonymous'),
      'content': content,
      'is_ai': isAi,
    });
  }

  // ── Unread Counts ─────────────────────────────────────────────────────────

  Future<int> getUnreadCount(String roomId, DateTime? lastReadAt) async {
    final dayAgo = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    final startTime = lastReadAt?.toIso8601String() ?? dayAgo;

    final response = await _supabase
        .from('chat_messages')
        .select('id')
        .eq('room_id', roomId)
        .gt('created_at', startTime)
        .count(CountOption.exact);
    
    return response.count;
  }

  Future<int> getTotalUnreadCount() async {
    final rooms = await getRooms();
    int total = 0;
    for (var room in rooms) {
      final lastRead = await getLastReadAt(room.id);
      total += await getUnreadCount(room.id, lastRead);
    }
    return total;
  }

  // ── Realtime stream ────────────────────────────────────────────────────────

  Stream<List<ChatMessage>> messagesStream(String roomId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => ChatMessage.fromMap(e)).toList());
  }

  // ── Read Status Helpers ───────────────────────────────────────────────────

  static const _readPrefix = 'last_read_room_';

  Future<void> markRoomAsRead(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_readPrefix$roomId', DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastReadAt(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('$_readPrefix$roomId');
    return val != null ? DateTime.parse(val) : null;
  }
}
