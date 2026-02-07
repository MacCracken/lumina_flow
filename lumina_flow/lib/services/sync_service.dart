import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/ritual.dart';

class SyncService {
  late Box<Task> _taskBox;
  late Box<Ritual> _ritualBox;
  late SupabaseClient _supabase;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _supabase = Supabase.instance.client;
      _taskBox = await Hive.openBox<Task>('tasks');
      _ritualBox = await Hive.openBox<Ritual>('rituals');
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize sync service: $e');
    }
  }

  // Task synchronization
  Future<void> syncTasks() async {
    if (!_isInitialized) return;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get local tasks
      final localTasks = _taskBox.values.toList();

      // Get remote tasks
      final remoteResponse = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId);

      final remoteTasks = <Task>[];
      for (final taskData in remoteResponse) {
        remoteTasks.add(Task(
          id: taskData['id'],
          title: taskData['title'],
          description: taskData['description'],
          status: TaskStatus.values.firstWhere(
            (e) => e.toString() == 'TaskStatus.${taskData['status']}',
            orElse: () => TaskStatus.todo,
          ),
          priority: TaskPriority.values.firstWhere(
            (e) => e.toString() == 'TaskPriority.${taskData['priority']}',
            orElse: () => TaskPriority.medium,
          ),
          createdAt: DateTime.parse(taskData['created_at']),
          dueDate: taskData['due_date'] != null 
              ? DateTime.parse(taskData['due_date']) 
              : null,
          boardId: taskData['board_id'],
          tags: List<String>.from(taskData['tags'] ?? []),
        ));
      }

      // Sync logic: last write wins
      await _mergeTasks(localTasks, remoteTasks, userId);

    } catch (e) {
      print('Failed to sync tasks: $e');
    }
  }

  Future<void> _mergeTasks(List<Task> localTasks, List<Task> remoteTasks, String userId) async {
    // Create maps for easier lookup
    final localMap = {for (var task in localTasks) task.id: task};
    final remoteMap = {for (var task in remoteTasks) task.id: task};

    // Find tasks that need to be uploaded
    final tasksToUpload = <Task>[];
    for (final task in localTasks) {
      if (!remoteMap.containsKey(task.id)) {
        tasksToUpload.add(task);
      }
    }

    // Find tasks that need to be downloaded
    final tasksToDownload = <Task>[];
    for (final task in remoteTasks) {
      if (!localMap.containsKey(task.id)) {
        tasksToDownload.add(task);
      }
    }

    // Handle conflicts (if any)
    final conflicts = <String>[];
    for (final task in localTasks) {
      if (remoteMap.containsKey(task.id)) {
        final remoteTask = remoteMap[task.id]!;
        // Simple conflict resolution: compare modification times
        // (this would require adding a modified_at field)
      }
    }

    // Upload new tasks
    for (final task in tasksToUpload) {
      await _uploadTask(task, userId);
    }

    // Download new tasks
    for (final task in tasksToDownload) {
      await _taskBox.put(task.id, task);
    }
  }

  Future<void> _uploadTask(Task task, String userId) async {
    try {
      final taskData = {
        'id': task.id,
        'user_id': userId,
        'title': task.title,
        'description': task.description,
        'status': task.status.toString().split('.').last,
        'priority': task.priority.toString().split('.').last,
        'created_at': task.createdAt.toIso8601String(),
        'due_date': task.dueDate?.toIso8601String(),
        'board_id': task.boardId,
        'tags': task.tags,
      };

      await _supabase.from('tasks').insert(taskData);
    } catch (e) {
      print('Failed to upload task: $e');
    }
  }

  // Ritual synchronization
  Future<void> syncRituals() async {
    if (!_isInitialized) return;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get local rituals
      final localRituals = _ritualBox.values.toList();

      // Get remote rituals
      final remoteResponse = await _supabase
          .from('rituals')
          .select()
          .eq('user_id', userId);

      final remoteRituals = <Ritual>[];
      for (final ritualData in remoteResponse) {
        remoteRituals.add(Ritual(
          id: ritualData['id'],
          title: ritualData['title'],
          description: ritualData['description'],
          isCompleted: ritualData['is_completed'],
          createdAt: DateTime.parse(ritualData['created_at']),
          lastCompleted: ritualData['last_completed'] != null
              ? DateTime.parse(ritualData['last_completed'])
              : null,
          resetTime: ritualData['reset_time'] != null
              ? DateTime.parse(ritualData['reset_time'])
              : null,
          streakCount: ritualData['streak_count'],
          frequency: RitualFrequency.values.firstWhere(
            (e) => e.toString() == 'RitualFrequency.${ritualData['frequency']}',
            orElse: () => RitualFrequency.daily,
          ),
        ));
      }

      // Merge rituals
      await _mergeRituals(localRituals, remoteRituals, userId);

    } catch (e) {
      print('Failed to sync rituals: $e');
    }
  }

  Future<void> _mergeRituals(List<Ritual> localRituals, List<Ritual> remoteRituals, String userId) async {
    final localMap = {for (var ritual in localRituals) ritual.id: ritual};
    final remoteMap = {for (var ritual in remoteRituals) ritual.id: ritual};

    // Upload new rituals
    for (final ritual in localRituals) {
      if (!remoteMap.containsKey(ritual.id)) {
        await _uploadRitual(ritual, userId);
      }
    }

    // Download new rituals
    for (final ritual in remoteRituals) {
      if (!localMap.containsKey(ritual.id)) {
        await _ritualBox.put(ritual.id, ritual);
      }
    }
  }

  Future<void> _uploadRitual(Ritual ritual, String userId) async {
    try {
      final ritualData = {
        'id': ritual.id,
        'user_id': userId,
        'title': ritual.title,
        'description': ritual.description,
        'is_completed': ritual.isCompleted,
        'created_at': ritual.createdAt.toIso8601String(),
        'last_completed': ritual.lastCompleted?.toIso8601String(),
        'reset_time': ritual.resetTime?.toIso8601String(),
        'streak_count': ritual.streakCount,
        'frequency': ritual.frequency.toString().split('.').last,
      };

      await _supabase.from('rituals').insert(ritualData);
    } catch (e) {
      print('Failed to upload ritual: $e');
    }
  }

  // Full synchronization
  Future<void> syncAll() async {
    if (!_isInitialized) return;

    await syncTasks();
    await syncRituals();
  }

  // Background sync
  void setupPeriodicSync() {
    // This would set up a timer or use work manager for periodic sync
    // Implementation depends on platform requirements
  }

  // Real-time subscriptions
  void setupRealtimeSync() {
    if (!_isInitialized) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _supabase.channel('lumina_flow_sync')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tasks',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
      ).subscribe((event) {
        // Handle real-time task updates
        if (event.eventType == PostgresChangeEvent.insert ||
            event.eventType == PostgresChangeEvent.update ||
            event.eventType == PostgresChangeEvent.delete) {
          syncTasks();
        }
      });

    _supabase.channel('lumina_flow_rituals_sync')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'rituals',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
      ).subscribe((event) {
        // Handle real-time ritual updates
        if (event.eventType == PostgresChangeEvent.insert ||
            event.eventType == PostgresChangeEvent.update ||
            event.eventType == PostgresChangeEvent.delete) {
          syncRituals();
        }
      });
  }
}