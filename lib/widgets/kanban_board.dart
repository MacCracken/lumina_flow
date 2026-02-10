import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/project.dart';

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
        final selectedProject = taskService.selectedProject;
        final columns = [
          {'id': 'todo', 'title': 'To Do', 'color': Colors.grey.shade400},
          {
            'id': 'in_progress',
            'title': 'In Progress',
            'color': Colors.blue.shade400
          },
          {'id': 'done', 'title': 'Done', 'color': Colors.green.shade400},
        ];

        return Column(
          children: [
            _buildHeader(selectedProject),
            Expanded(
              child: selectedProject == null
                  ? _buildNoProjectSelected()
                  : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      itemCount: columns.length,
                      itemBuilder: (context, index) {
                        final column = columns[index];
                        final tasks = taskService.getTasksForColumn(
                          column['id'] as String,
                        );

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

  Widget _buildNoProjectSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No project selected',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a project from the sidebar or create a new one',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Project? project) {
    Color? projectColor;
    if (project != null) {
      try {
        final colorValue = int.parse(
          project.color.replaceFirst('#', '0xFF'),
        );
        projectColor = Color(colorValue);
      } catch (_) {
        projectColor = Colors.blue;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (project != null) ...[
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                color: projectColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  project.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else
            const Text(
              'Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Spacer(),
          if (project != null) ...[
            IconButton(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add),
              tooltip: 'Add Task',
            ),
            IconButton(
              onPressed: () => _showProjectSettings(project),
              icon: const Icon(Icons.settings),
              tooltip: 'Project Settings',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColumn(
    String columnId,
    String title,
    Color color,
    List<Task> tasks,
  ) {
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
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                _moveTaskToColumn(details.data, columnId);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Draggable<Task>(
                      data: task,
                      feedback: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 280,
                          child: _buildTaskCard(task, isDragging: true),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildTaskCard(task),
                      ),
                      child: _buildTaskCard(task),
                    );
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
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }

  void _moveTaskToColumn(Task task, String columnId) {
    TaskStatus newStatus;
    switch (columnId) {
      case 'todo':
        newStatus = TaskStatus.todo;
        break;
      case 'in_progress':
        newStatus = TaskStatus.inProgress;
        break;
      case 'done':
        newStatus = TaskStatus.done;
        break;
      default:
        return;
    }

    task.status = newStatus;
    context.read<TaskService>().updateTask(task);
  }

  Widget _buildTaskCard(Task task, {bool isDragging = false}) {
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isDragging ? 8 : 1,
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        onLongPress: () => _showTaskMenu(task),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (task.taskKey != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.taskKey!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (task.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog({String? columnId}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priority == TaskPriority.high
                                ? Colors.red
                                : priority == TaskPriority.medium
                                    ? Colors.orange
                                    : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_capitalizeFirst(priority.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedPriority = value!;
                  });
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
                  final taskService = context.read<TaskService>();
                  taskService.addTask(
                    titleController.text,
                    description: descController.text.isNotEmpty
                        ? descController.text
                        : null,
                    priority: selectedPriority,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (task.taskKey != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.taskKey!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(task.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              Text(task.description!),
              const SizedBox(height: 16),
            ],
            _buildDetailRow(
              'Priority',
              _capitalizeFirst(task.priority.name),
            ),
            _buildDetailRow(
              'Status',
              _capitalizeFirst(task.status.name.replaceAll('_', ' ')),
            ),
            if (task.dueDate != null)
              _buildDetailRow('Due', _formatDate(task.dueDate!)),
            _buildDetailRow('Created', _formatDate(task.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTaskDialog(task);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    final TextEditingController titleController =
        TextEditingController(text: task.title);
    final TextEditingController descController =
        TextEditingController(text: task.description ?? '');
    TaskPriority selectedPriority = task.priority;
    TaskStatus selectedStatus = task.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
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
                      child: Text(_capitalizeFirst(priority.name)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        _capitalizeFirst(status.name.replaceAll('_', ' ')),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  task.title = titleController.text;
                  task.description = descController.text.isNotEmpty
                      ? descController.text
                      : null;
                  task.priority = selectedPriority;
                  task.status = selectedStatus;
                  context.read<TaskService>().updateTask(task);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
              _showEditTaskDialog(task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move),
            title: const Text('Move to Project'),
            onTap: () {
              Navigator.pop(context);
              _showMoveToProjectDialog(task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskService>().deleteTask(task.id);
            },
          ),
        ],
      ),
    );
  }

  void _showMoveToProjectDialog(Task task) {
    final taskService = context.read<TaskService>();
    final projects = taskService.activeProjects;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Project'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final isCurrentProject = project.id == task.projectId;

              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _parseColor(project.color),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(project.name),
                subtitle: Text(project.key),
                trailing: isCurrentProject
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: isCurrentProject
                    ? null
                    : () {
                        taskService.moveTaskToProject(task.id, project.id);
                        Navigator.pop(context);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showProjectSettings(Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Project'),
            onTap: () {
              Navigator.pop(context);
              _showEditProjectDialog(project);
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive Project'),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskService>().archiveProject(project.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Project',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('This will delete all tasks in this project'),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteProject(project);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    final TextEditingController nameController =
        TextEditingController(text: project.name);
    final TextEditingController keyController =
        TextEditingController(text: project.key);
    final TextEditingController descController =
        TextEditingController(text: project.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Project Key',
                helperText: 'Used for task IDs (e.g., MP-1)',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
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
              if (nameController.text.isNotEmpty &&
                  keyController.text.isNotEmpty) {
                project.name = nameController.text;
                project.key = keyController.text.toUpperCase();
                project.description = descController.text.isNotEmpty
                    ? descController.text
                    : null;
                context.read<TaskService>().updateProject(project);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? '
          'This will also delete all tasks in this project. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskService>().deleteProject(project.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
