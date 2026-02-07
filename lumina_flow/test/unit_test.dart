import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:lumina_flow/models/task.dart';
import 'package:lumina_flow/services/task_service.dart';

void main() {
  group('TaskService Tests', () {
    late TaskService taskService;

    setUp(() async {
      await setUpTestHive();
      Hive.registerAdapter(TaskAdapter());
      taskService = TaskService();
      await taskService.init();
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    test('should add task successfully', () async {
      const taskTitle = 'Test Task';
      await taskService.addTask(taskTitle);

      expect(taskService.tasks.length, 1);
      expect(taskService.tasks.first.title, taskTitle);
    });

    test('should delete task successfully', () async {
      await taskService.addTask('Test Task');
      final taskId = taskService.tasks.first.id;

      await taskService.deleteTask(taskId);

      expect(taskService.tasks.length, 0);
    });

    test('should update task status', () async {
      await taskService.addTask('Test Task');
      final task = taskService.tasks.first;

      final updatedTask = task.copyWith(status: TaskStatus.inProgress);
      await taskService.updateTask(updatedTask);

      expect(taskService.tasks.first.status, TaskStatus.inProgress);
    });

    test('should add ritual successfully', () async {
      const ritualTitle = 'Morning Meditation';
      await taskService.addRitual(ritualTitle);

      expect(taskService.rituals.length, 1);
      expect(taskService.rituals.first.title, ritualTitle);
    });

    test('should toggle ritual completion', () async {
      await taskService.addRitual('Test Ritual');
      final ritualId = taskService.rituals.first.id;

      await taskService.toggleRitualCompletion(ritualId);

      expect(taskService.rituals.first.isCompleted, true);
    });
  });
}