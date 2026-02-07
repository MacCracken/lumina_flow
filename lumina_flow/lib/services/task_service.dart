import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/ritual.dart';
import '../models/board.dart';

class TaskService extends ChangeNotifier {
  late Box<Task> _taskBox;
  late Box<Ritual> _ritualBox;
  late Box<Board> _boardBox;
  late Box<BoardColumn> _columnBox;
  
  List<Task> _tasks = [];
  List<Ritual> _rituals = [];
  List<Board> _boards = [];
  List<BoardColumn> _columns = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Ritual> get rituals => List.unmodifiable(_rituals);
  List<Board> get boards => List.unmodifiable(_boards);
  List<BoardColumn> get columns => List.unmodifiable(_columns);

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    _ritualBox = await Hive.openBox<Ritual>('rituals');
    _boardBox = await Hive.openBox<Board>('boards');
    _columnBox = await Hive.openBox<BoardColumn>('columns');

    _loadData();
    
    // Initialize default board if none exists
    if (_boards.isEmpty) {
      await _createDefaultBoard();
    }
    
    // Check for ritual resets
    await _checkRitualResets();
  }

  void _loadData() {
    _tasks = _taskBox.values.toList();
    _rituals = _ritualBox.values.toList();
    _boards = _boardBox.values.toList();
    _columns = _columnBox.values.toList();
    notifyListeners();
  }

  Future<void> _createDefaultBoard() async {
    const uuid = Uuid();
    
    final board = Board(
      id: uuid.v4(),
      title: 'My Projects',
      createdAt: DateTime.now(),
    );
    
    final todoColumn = BoardColumn(
      id: uuid.v4(),
      title: 'To Do',
      order: 0,
    );
    
    final inProgressColumn = BoardColumn(
      id: uuid.v4(),
      title: 'In Progress',
      order: 1,
    );
    
    final doneColumn = BoardColumn(
      id: uuid.v4(),
      title: 'Done',
      order: 2,
    );
    
    await _boardBox.put(board.id, board);
    await _columnBox.put(todoColumn.id, todoColumn);
    await _columnBox.put(inProgressColumn.id, inProgressColumn);
    await _columnBox.put(doneColumn.id, doneColumn);
    
    board.columnIds = [todoColumn.id, inProgressColumn.id, doneColumn.id];
    await board.save();
    
    _boards.add(board);
    _columns.addAll([todoColumn, inProgressColumn, doneColumn]);
    
    notifyListeners();
  }

  Future<void> _checkRitualResets() async {
    for (final ritual in _rituals) {
      ritual.resetIfNeeded();
    }
  }

  Future<void> addTask(String title, {String? description, TaskPriority? priority, String? boardId}) async {
    const uuid = Uuid();
    final task = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      priority: priority ?? TaskPriority.medium,
      createdAt: DateTime.now(),
      boardId: boardId,
    );
    
    await _taskBox.put(task.id, task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await task.save();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Future<void> addRitual(String title, {String? description}) async {
    const uuid = Uuid();
    final ritual = Ritual(
      id: uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    
    await _ritualBox.put(ritual.id, ritual);
    _rituals.add(ritual);
    notifyListeners();
  }

  Future<void> updateRitual(Ritual ritual) async {
    await ritual.save();
    notifyListeners();
  }

  Future<void> toggleRitualCompletion(String ritualId) async {
    final ritual = _rituals.firstWhere((r) => r.id == ritualId);
    if (!ritual.isCompleted) {
      ritual.markCompleted();
    } else {
      ritual.isCompleted = false;
      await ritual.save();
    }
    notifyListeners();
  }

  Future<void> deleteRitual(String ritualId) async {
    await _ritualBox.delete(ritualId);
    _rituals.removeWhere((ritual) => ritual.id == ritualId);
    notifyListeners();
  }

  List<Task> getTasksForColumn(String columnId) {
    return _tasks.where((task) {
      // This would need to be implemented based on your logic
      // For now, we'll use status as a proxy
      switch (columnId) {
        case 'todo':
          return task.status == TaskStatus.todo;
        case 'in_progress':
          return task.status == TaskStatus.inProgress;
        case 'done':
          return task.status == TaskStatus.done;
        default:
          return false;
      }
    }).toList();
  }
}