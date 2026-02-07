import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/board.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final columns = [
          {'id': 'todo', 'title': 'To Do', 'color': Colors.grey.shade400},
          {'id': 'in_progress', 'title': 'In Progress', 'color': Colors.blue.shade400},
          {'id': 'done', 'title': 'Done', 'color': Colors.green.shade400},
        ];

        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: columns.length,
                itemBuilder: (context, index) {
                  final column = columns[index];
                  final tasks = taskService.getTasksForColumn(column['id'] as String);
                  
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildColumn(
                      column['id'] as String,
                      column['title'] as String,
                      column['color'] as Color,
                      tasks,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'My Projects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String columnId, String title, Color color, List<Task> tasks) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                // TODO: Implement task movement between columns
              },
              builder: (context, candidateData, rejectedData) {
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    // TODO: Implement task reordering
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task, key: ValueKey(task.id));
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: () => _showAddTaskDialog(columnId: columnId),
              icon: Icon(Icons.add, size: 16),
              label: Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, {Key? key}) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: task.description != null ? Text(task.description!) : null,
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        onTap: () => _showTaskDetails(task),
        onLongPress: () => _showTaskMenu(task),
      ),
    );
  }

  void _showAddTaskDialog({String? columnId}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                selectedPriority = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TaskService>().addTask(
                  titleController.text,
                  description: descController.text.isNotEmpty ? descController.text : null,
                  priority: selectedPriority,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              Text(task.description!),
              const SizedBox(height: 16),
            ],
            Text('Priority: ${task.priority.toString().split('.').last}'),
            Text('Status: ${task.status.toString().split('.').last}'),
            if (task.dueDate != null)
              Text('Due: ${_formatDate(task.dueDate!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTaskMenu(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskService>().deleteTask(task.id);
            },
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Toggle E-Reader Mode'),
            onTap: () {
              Navigator.pop(context);
              context.read<ThemeService>().toggleEReaderMode();
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}