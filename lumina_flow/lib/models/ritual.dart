import 'package:hive/hive.dart';

part 'ritual.g.dart';

@HiveType(typeId: 3)
class Ritual extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? lastCompleted;
  
  @HiveField(6)
  DateTime? resetTime;
  
  @HiveField(7)
  int streakCount;
  
  @HiveField(8)
  RitualFrequency frequency;

  Ritual({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.lastCompleted,
    this.resetTime,
    this.streakCount = 0,
    this.frequency = RitualFrequency.daily,
  });

  void markCompleted() {
    isCompleted = true;
    lastCompleted = DateTime.now();
    streakCount++;
    save();
  }

  void resetIfNeeded() {
    final now = DateTime.now();
    final lastReset = resetTime ?? createdAt;
    
    if (frequency == RitualFrequency.daily) {
      if (now.day != lastReset.day || now.month != lastReset.month || now.year != lastReset.year) {
        isCompleted = false;
        resetTime = now;
        save();
      }
    }
  }

  Ritual copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? lastCompleted,
    DateTime? resetTime,
    int? streakCount,
    RitualFrequency? frequency,
  }) {
    return Ritual(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      resetTime: resetTime ?? this.resetTime,
      streakCount: streakCount ?? this.streakCount,
      frequency: frequency ?? this.frequency,
    );
  }
}

@HiveType(typeId: 4)
enum RitualFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
}