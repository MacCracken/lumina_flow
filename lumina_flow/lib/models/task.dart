import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  TaskStatus status;
  
  @HiveField(4)
  TaskPriority priority;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime? dueDate;
  
  @HiveField(7)
  String? boardId;
  
  @HiveField(8)
  List<String> tags;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.boardId,
    this.tags = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    String? boardId,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      boardId: boardId ?? this.boardId,
      tags: tags ?? this.tags,
    );
  }
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}