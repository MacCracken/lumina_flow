import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/board.dart';
import '../common/utils.dart';
import '../common/constants.dart';
import 'dialogs/task_dialogs.dart';
import 'dialogs/project_dialogs.dart';

class PaginatedTaskColumn extends StatefulWidget {
  final BoardColumn column;
  final Project project;

  const PaginatedTaskColumn({
    super.key,
    required this.column,
    required this.project,
  });

  @override
  State<PaginatedTaskColumn> createState() => _PaginatedTaskColumnState();
}

class _PaginatedTaskColumnState extends State<PaginatedTaskColumn> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final color = parseColor(widget.column.color);
    final totalCount = taskService.getTaskCountForColumn(
      widget.column.id,
      projectId: widget.project.id,
    );
    final tasks = taskService.getTasksForColumnPaginated(
      widget.column.id,
      projectId: widget.project.id,
      page: _currentPage,
    );
    final hasMore = taskService.hasMoreTasksForColumn(
      widget.column.id,
      projectId: widget.project.id,
      page: _currentPage,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildColumnHeader(color, totalCount),
          Expanded(
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                details.data.status = widget.column.status;
                context.read<TaskService>().updateTask(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.smallPadding,
                  ),
                  itemCount: tasks.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == tasks.length) {
                      return _buildLoadMoreButton(taskService);
                    }
                    final task = tasks[index];
                    return _buildDraggableTask(task);
                  },
                );
              },
            ),
          ),
          _buildAddTaskButton(),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(Color color, int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.headerPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.column.order,
            child: Icon(Icons.drag_handle,
                color: color, size: AppConstants.iconSizeLarge),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              widget.column.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: AppConstants.tinyPadding,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalCount',
              style: TextStyle(
                fontSize: AppConstants.taskKeyFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: color, size: AppConstants.iconSizeLarge),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditColumnDialog(context, widget.project, widget.column);
              } else if (value == 'delete') {
                _showDeleteColumnDialog(context, widget.project, widget.column);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No tasks',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadMoreButton(TaskService taskService) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: TextButton(
        onPressed: () {
          setState(() {
            _currentPage++;
          });
        },
        child: const Text('Load more'),
      ),
    );
  }

  Widget _buildDraggableTask(Task task) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: AppConstants.elevationHigh,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: SizedBox(
          width: AppConstants.columnWidth - 20,
          child: _buildTaskCard(task, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCard(task),
      ),
      child: _buildTaskCard(task),
    );
  }

  Widget _buildTaskCard(Task task, {bool isDragging = false}) {
    final priorityColor = getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardMarginHorizontal,
        vertical: AppConstants.cardMarginVertical,
      ),
      elevation:
          isDragging ? AppConstants.elevationHigh : AppConstants.elevationLow,
      child: InkWell(
        onTap: () => showTaskDetails(context, task),
        onLongPress: () => showTaskMenu(context, task),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (task.taskKey != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: AppConstants.tinyPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall),
                      ),
                      child: Text(
                        task.taskKey!,
                        style: TextStyle(
                          fontSize: AppConstants.taskKeyFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
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
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (task.description != null) ...[
                const SizedBox(height: AppConstants.tinyPadding),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: AppConstants.descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Wrap(
                  spacing: AppConstants.tinyPadding,
                  runSpacing: AppConstants.tinyPadding,
                  children: task.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: AppConstants.tinyPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall),
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
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: AppConstants.iconSizeSmall,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: AppConstants.tinyPadding),
                    Text(
                      formatDate(task.dueDate!),
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

  Widget _buildAddTaskButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: TextButton.icon(
        onPressed: () => showAddTaskDialog(context, columnId: widget.column.id),
        icon: const Icon(Icons.add, size: AppConstants.iconSizeMedium),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showEditColumnDialog(
      BuildContext context, Project project, BoardColumn column) {
    final titleController = TextEditingController(text: column.title);
    TaskStatus selectedStatus = column.status;
    String selectedColor = column.color;

    final colors = [
      '#6B7280',
      '#3B82F6',
      '#10B981',
      '#F59E0B',
      '#EF4444',
      '#8B5CF6',
      '#EC4899',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Column Name',
                ),
              ),
              const SizedBox(height: AppConstants.headerPadding),
              DropdownButtonFormField<TaskStatus>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: AppConstants.headerPadding),
              Wrap(
                spacing: AppConstants.smallPadding,
                children: colors.map((color) {
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
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
                  final updatedColumn = widget.column.copyWith(
                    title: titleController.text,
                    status: selectedStatus,
                    color: selectedColor,
                  );
                  context
                      .read<TaskService>()
                      .updateColumn(widget.project.id, updatedColumn);
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

  void _showDeleteColumnDialog(
      BuildContext context, Project project, BoardColumn column) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Column'),
        content: Text(
            'Are you sure you want to delete "${column.title}"? Tasks in this column will need to be moved to another column.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TaskService>().deleteColumn(project.id, column.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selector<TaskService, Project?>(
          selector: (_, service) => service.selectedProject,
          builder: (context, selectedProject, _) =>
              _buildHeader(selectedProject),
        ),
        Expanded(
          child: Selector<TaskService, String?>(
            selector: (_, service) => service.selectedProjectId,
            builder: (context, selectedProjectId, _) {
              if (selectedProjectId == null) {
                return _buildNoProjectSelected();
              }
              return Selector<TaskService, List<BoardColumn>>(
                selector: (_, service) =>
                    service.selectedProject?.columns ?? [],
                builder: (context, columns, _) => ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: columns.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final columnIds = columns.map((c) => c.id).toList();
                    final id = columnIds.removeAt(oldIndex);
                    columnIds.insert(newIndex, id);
                    context
                        .read<TaskService>()
                        .reorderColumns(selectedProjectId, columnIds);
                  },
                  itemBuilder: (context, index) {
                    final column = columns[index];
                    return Selector<TaskService, Project?>(
                      selector: (_, service) => service.selectedProject,
                      builder: (context, project, _) {
                        if (project == null) return const SizedBox.shrink();
                        return Container(
                          key: ValueKey(column.id),
                          width: AppConstants.columnWidth,
                          margin: const EdgeInsets.only(
                              right: AppConstants.columnMargin),
                          child: PaginatedTaskColumn(
                            column: column,
                            project: project,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
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
      projectColor = parseColor(project.color);
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
                  project.projectKey,
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
              onPressed: () => _showAddColumnDialog(context, project),
              icon: const Icon(Icons.view_column),
              tooltip: 'Add Column',
            ),
            IconButton(
              onPressed: () => showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              tooltip: 'Add Task',
            ),
            IconButton(
              onPressed: () => showProjectSettings(context, project),
              icon: const Icon(Icons.settings),
              tooltip: 'Project Settings',
            ),
          ],
        ],
      ),
    );
  }

  void _showAddColumnDialog(BuildContext context, Project project) {
    final titleController = TextEditingController();
    TaskStatus selectedStatus = TaskStatus.todo;
    String selectedColor = '#6B7280';

    final colors = [
      '#6B7280',
      '#3B82F6',
      '#10B981',
      '#F59E0B',
      '#EF4444',
      '#8B5CF6',
      '#EC4899',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Column Name',
                  hintText: 'e.g., In Review',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: colors.map((color) {
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
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
                  final column = BoardColumn(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    status: selectedStatus,
                    color: selectedColor,
                  );
                  context.read<TaskService>().addColumn(project.id, column);
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
}
