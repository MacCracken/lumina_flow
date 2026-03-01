import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photisnadi/widgets/common/common_widgets.dart';
import 'package:photisnadi/widgets/common/project_header.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No tasks',
              subtitle: 'Create your first task',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No tasks'), findsOneWidget);
      expect(find.text('Create your first task'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No tasks',
              actionLabel: 'Add Task',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Task'), findsOneWidget);
      await tester.tap(find.text('Add Task'));
      expect(actionCalled, isTrue);
    });

    testWidgets('should not display subtitle when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No tasks',
            ),
          ),
        ),
      );

      expect(find.text('No tasks'), findsOneWidget);
    });
  });

  group('ColorPicker Widget Tests', () {
    testWidgets('should display all default colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPicker(
              selectedColor: '#3B82F6',
              onColorSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(7));
    });

    testWidgets('should call onColorSelected when color is tapped',
        (tester) async {
      String? selectedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPicker(
              selectedColor: '#3B82F6',
              onColorSelected: (color) => selectedColor = color,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(selectedColor, isNotNull);
    });

    testWidgets('should display check icon on selected color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPicker(
              selectedColor: '#3B82F6',
              onColorSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('ColorBadge Widget Tests', () {
    testWidgets('should display text with color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorBadge(
              text: 'High',
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('should use custom font size when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorBadge(
              text: 'Test',
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test'));
      expect(textWidget.style?.fontSize, 16);
    });
  });

  group('StreakBadge Widget Tests', () {
    testWidgets('should display streak count when greater than 0',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(streakCount: 5),
          ),
        ),
      );

      expect(find.text('5🔥'), findsOneWidget);
    });

    testWidgets('should return empty widget when streak is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(streakCount: 0),
          ),
        ),
      );

      expect(find.byType(StreakBadge), findsOneWidget);
      expect(find.text('0🔥'), findsNothing);
    });

    testWidgets('should return empty widget when streak is negative',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(streakCount: -1),
          ),
        ),
      );

      expect(find.text('-1🔥'), findsNothing);
    });
  });

  group('CountBadge Widget Tests', () {
    testWidgets('should display count with color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountBadge(count: 10, color: Colors.green),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });
  });

  group('EditDeleteMenu Widget Tests', () {
    testWidgets('should display edit and delete options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteMenu(
              onSelected: (_) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should show menu items when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteMenu(
              onSelected: (_) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should not show edit when onEdit is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteMenu(
              onSelected: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('ProjectHeader Widget Tests', () {
    testWidgets('should display Projects title when project is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectHeader(project: null),
          ),
        ),
      );

      expect(find.text('Projects'), findsOneWidget);
    });
  });
}
