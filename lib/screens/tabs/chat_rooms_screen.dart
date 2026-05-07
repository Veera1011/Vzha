import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';
import '../../widgets/shimmer_skeleton.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen>
    with SingleTickerProviderStateMixin {
  final _chatService = ChatService();
  late TabController _tabController;
  List<ChatRoom> _packageRooms = [];
  List<ChatRoom> _topicRooms = [];
  Map<String, int> _unreadCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRooms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _chatService.getRooms();
      final counts = <String, int>{};
      
      for (var room in rooms) {
        final lastRead = await _chatService.getLastReadAt(room.id);
        counts[room.id] = await _chatService.getUnreadCount(room.id, lastRead);
      }

      setState(() {
        _packageRooms = rooms.where((r) => r.type == 'package').toList();
        _topicRooms = rooms.where((r) => r.type == 'topic').toList();
        _unreadCounts = counts;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _packageRooms = [
          ChatRoom(id: 'pkg-react', name: 'react', type: 'package', description: 'Discuss the React ecosystem'),
          ChatRoom(id: 'pkg-flutter', name: 'flutter', type: 'package', description: 'Flutter & Dart packages'),
          ChatRoom(id: 'pkg-nextjs', name: 'next.js', type: 'package', description: 'Next.js & Vercel'),
          ChatRoom(id: 'pkg-nodejs', name: 'node.js', type: 'package', description: 'Node & npm packages'),
          ChatRoom(id: 'pkg-graphql', name: 'graphql', type: 'package', description: 'GraphQL clients & schemas'),
        ];
        _topicRooms = [
          ChatRoom(id: 'top-security', name: 'security', type: 'topic', description: 'CVEs, advisories & best practices'),
          ChatRoom(id: 'top-devops', name: 'devops', type: 'topic', description: 'CI/CD, Docker & Kubernetes'),
          ChatRoom(id: 'top-ai', name: 'ai-ml', type: 'topic', description: 'AI/ML frameworks & research'),
          ChatRoom(id: 'top-architecture', name: 'architecture', type: 'topic', description: 'System design & patterns'),
          ChatRoom(id: 'top-open-source', name: 'open-source', type: 'topic', description: 'OSS projects & contributions'),
        ];
        _loading = false;
      });
    }
  }

  void _openRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(room: room)),
    );
  }

  Future<void> _showCreateRoomDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = _tabController.index == 0 ? 'package' : 'topic';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.fromLTRB(
              24, 20, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text('Create a new room', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Start a discussion channel for the community.', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 20),

                // Room type toggle
                Text('Room type', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'package', label: Text('Package'), icon: Icon(Icons.inventory_2_outlined, size: 16)),
                    ButtonSegment(value: 'topic', label: Text('Topic'), icon: Icon(Icons.tag, size: 16)),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (s) => setLocal(() => selectedType = s.first),
                ),
                const SizedBox(height: 16),

                // Name field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Room name',
                    hintText: selectedType == 'package' ? 'e.g. react, tailwind…' : 'e.g. career, open-source…',
                    prefixText: '#',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Description field
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Short description (optional)',
                    hintText: 'What is this room about?',
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create room'),
                  onPressed: () async {
                    final name = nameController.text.trim().toLowerCase().replaceAll(' ', '-');
                    if (name.isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      await _chatService.createRoom(
                        name: name,
                        type: selectedType,
                        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                      );
                      await _loadRooms();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not create room: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    nameController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight - 8),
        child: Material(
          color: cs.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 2.5,
            dividerColor: cs.outlineVariant,
            tabs: const [
              Tab(text: 'Packages', icon: Icon(Icons.inventory_2_outlined, size: 18)),
              Tab(text: 'Topics', icon: Icon(Icons.tag, size: 18)),
            ],
          ),
        ),
      ),
      body: _loading
          ? const ShimmerListLoading(itemCount: 8)
            : TabBarView(
                controller: _tabController,
                children: [
                  _RoomList(
                    rooms: _packageRooms,
                    unreadCounts: _unreadCounts,
                    onTap: _openRoom,
                    onRefresh: _loadRooms,
                    emptyLabel: 'No package rooms yet.\nCreate one!',
                  ),
                  _RoomList(
                    rooms: _topicRooms,
                    unreadCounts: _unreadCounts,
                    onTap: _openRoom,
                    onRefresh: _loadRooms,
                    emptyLabel: 'No topic rooms yet.\nCreate one!',
                  ),
                ],
              ),
      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        icon: const Icon(Icons.add),
        label: const Text('New room'),
        tooltip: 'Create a new chat room',
      ),
    );
  }
}

// ── Room list ─────────────────────────────────────────────────────────────────

class _RoomList extends StatelessWidget {
  final List<ChatRoom> rooms;
  final Map<String, int> unreadCounts;
  final ValueChanged<ChatRoom> onTap;
  final RefreshCallback onRefresh;
  final String emptyLabel;

  const _RoomList({
    required this.rooms,
    required this.unreadCounts,
    required this.onTap,
    required this.onRefresh,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (rooms.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.forum_outlined, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(emptyLabel, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88), // space for FAB
        itemCount: rooms.length,
        itemBuilder: (context, i) {
          final room = rooms[i];
          return _RoomTile(
            room: room, 
            onTap: () => onTap(room),
            unreadCount: unreadCounts[room.id] ?? 0,
          );
        },
      ),
    );
  }
}

// ── SO-style room tile ────────────────────────────────────────────────────────

class _RoomTile extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;
  final int unreadCount;

  const _RoomTile({required this.room, required this.onTap, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isPackage = room.type == 'package';

    return InkWell(
      onTap: onTap,
      child: Badge(
        label: Text(unreadCount.toString()),
        isLabelVisible: unreadCount > 0,
        alignment: const Alignment(0.95, -0.7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: icon box ───────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPackage ? cs.primaryContainer : cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPackage ? Icons.inventory_2_outlined : Icons.label_outline,
                color: isPackage ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // ── Center: name + description + tags ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name with # prefix
                  Row(
                    children: [
                      Text('#', style: tt.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Text(
                          room.name,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (room.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      room.description!,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // ── Meta row (type tag + "Join" indicator) ──────────────
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPackage ? cs.primaryContainer : cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPackage ? 'package' : 'topic',
                          style: tt.labelSmall?.copyWith(
                            color: isPackage ? cs.onPrimaryContainer : cs.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.circle, size: 6, color: Colors.green.shade400),
                      const SizedBox(width: 4),
                      Text('Active', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right: arrow ─────────────────────────────────────────────
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    ),
  );
}
}
