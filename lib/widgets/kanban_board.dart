import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/board.dart';
import '../common/utils.dart';
import '../common/constants.dart';
import '../widgets/dialogs/task_dialogs.dart';
import '../widgets/dialogs/project_dialogs.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/common/task_card.dart';
import '../widgets/common/column_widgets.dart';
import '../widgets/common/search_filter_bar.dart';

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
                final task = details.data;
                final taskService = context.read<TaskService>();

                if (widget.column.status == TaskStatus.done &&
                    taskService.isTaskBlocked(task)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Cannot complete "${task.title}": dependencies not done'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                task.status = widget.column.status;
                taskService.updateTask(task);
              },
              builder: (context, candidateData, rejectedData) {
                final isDropTarget = candidateData.isNotEmpty;

                if (tasks.isEmpty && !isDropTarget) {
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
    return ColumnHeader(
      column: widget.column,
      color: color,
      totalCount: totalCount,
      onEdit: () =>
          showEditColumnDialog(context, widget.project, widget.column),
      onDelete: () =>
          showDeleteColumnDialog(context, widget.project, widget.column),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.inbox,
      title: 'No tasks',
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
          child: TaskCard(
            task: task,
            isDragging: true,
            onTap: () => showTaskDetails(context, task),
            onLongPress: () => showTaskMenu(context, task),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: TaskCard(
          task: task,
          onTap: () => showTaskDetails(context, task),
          onLongPress: () => showTaskMenu(context, task),
        ),
      ),
      child: TaskCard(
        task: task,
        onTap: () => showTaskDetails(context, task),
        onLongPress: () => showTaskMenu(context, task),
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
    return const EmptyState(
      icon: Icons.folder_open,
      title: 'No project selected',
      subtitle: 'Select a project from the sidebar or create a new one',
    );
  }

  Widget _buildHeader(Project? project) {
    Color? projectColor;
    if (project != null) {
      projectColor = parseColor(project.color);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  onPressed: () => showAddColumnDialog(context, project),
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
          if (project != null) ...[
            const SizedBox(height: 12),
            const SearchFilterBar(),
          ],
        ],
      ),
    );
  }
}
