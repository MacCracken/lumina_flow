import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../models/project.dart';

class ProjectSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const ProjectSidebar({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<ProjectSidebar> createState() => _ProjectSidebarState();
}

class _ProjectSidebarState extends State<ProjectSidebar> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final activeProjects = taskService.activeProjects;
        final archivedProjects = taskService.archivedProjects;
        final selectedProjectId = taskService.selectedProjectId;

        return Container(
          width: widget.isCollapsed ? 60 : 240,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: widget.isCollapsed
                    ? _buildCollapsedView(activeProjects, selectedProjectId)
                    : _buildExpandedView(
                        activeProjects,
                        archivedProjects,
                        selectedProjectId,
                        taskService,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (widget.isCollapsed) {
      return Container(
        height: 60,
        child: Center(
          child: IconButton(
            onPressed: widget.onToggleCollapse,
            icon: const Icon(Icons.keyboard_double_arrow_right),
            tooltip: 'Expand',
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onToggleCollapse,
            icon: const Icon(Icons.keyboard_double_arrow_left),
            tooltip: 'Collapse',
          ),
          const Expanded(
            child: Text(
              'Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _showAddProjectDialog,
            icon: const Icon(Icons.add),
            tooltip: 'New Project',
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(
    List<Project> projects,
    String? selectedProjectId,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final isSelected = project.id == selectedProjectId;
        final color = _parseColor(project.color);

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Tooltip(
            message: project.name,
            child: GestureDetector(
              onTap: () =>
                  context.read<TaskService>().selectProject(project.id),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    project.key.length > 2
                        ? project.key.substring(0, 2)
                        : project.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedView(
    List<Project> activeProjects,
    List<Project> archivedProjects,
    String? selectedProjectId,
    TaskService taskService,
  ) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (activeProjects.isEmpty)
          _buildEmptyState()
        else
          ...activeProjects.map((project) => _buildProjectTile(
                project,
                selectedProjectId,
                taskService,
              )),
        if (archivedProjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Icon(
                    _showArchived
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Archived (${archivedProjects.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showArchived)
            ...archivedProjects.map((project) => _buildProjectTile(
                  project,
                  selectedProjectId,
                  taskService,
                  isArchived: true,
                )),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showAddProjectDialog,
            child: const Text('Create your first project'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTile(
    Project project,
    String? selectedProjectId,
    TaskService taskService, {
    bool isArchived = false,
  }) {
    final isSelected = project.id == selectedProjectId;
    final color = _parseColor(project.color);
    final taskCount = taskService.getTasksForProject(project.id).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isArchived
            ? null
            : () => taskService.selectProject(project.id),
        onLongPress: () => _showProjectMenu(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    project.key.length > 2
                        ? project.key.substring(0, 2)
                        : project.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isArchived ? Colors.grey : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$taskCount tasks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isArchived)
                Icon(
                  Icons.archive,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectMenu(Project project) {
    final taskService = context.read<TaskService>();

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
          if (project.isArchived)
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('Restore Project'),
              onTap: () {
                Navigator.pop(context);
                project.isArchived = false;
                taskService.updateProject(project);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Project'),
              onTap: () {
                Navigator.pop(context);
                taskService.archiveProject(project.id);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Project',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteProject(project);
            },
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController keyController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String selectedColor = '#4A90E2';

    final colors = [
      '#4A90E2',
      '#50C878',
      '#FF6B6B',
      '#FFB347',
      '#9B59B6',
      '#3498DB',
      '#1ABC9C',
      '#E74C3C',
      '#F39C12',
      '#8E44AD',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g., Mobile App',
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    // Auto-generate key from name
                    if (keyController.text.isEmpty ||
                        keyController.text ==
                            _generateKey(
                              nameController.text.substring(
                                0,
                                nameController.text.length > 1
                                    ? nameController.text.length - 1
                                    : 0,
                              ),
                            )) {
                      keyController.text = _generateKey(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Project Key',
                    hintText: 'e.g., MA',
                    helperText: 'Used for task IDs (e.g., MA-1, MA-2)',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 5,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((colorHex) {
                    final color = _parseColor(colorHex);
                    final isSelected = selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = colorHex;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
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
                if (nameController.text.isNotEmpty &&
                    keyController.text.isNotEmpty) {
                  context.read<TaskService>().addProject(
                        nameController.text,
                        keyController.text,
                        description: descController.text.isNotEmpty
                            ? descController.text
                            : null,
                        color: selectedColor,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
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
    String selectedColor = project.color;

    final colors = [
      '#4A90E2',
      '#50C878',
      '#FF6B6B',
      '#FFB347',
      '#9B59B6',
      '#3498DB',
      '#1ABC9C',
      '#E74C3C',
      '#F39C12',
      '#8E44AD',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Project Key',
                    helperText: 'Changing the key affects new task IDs only',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 5,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((colorHex) {
                    final color = _parseColor(colorHex);
                    final isSelected = selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = colorHex;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
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
                if (nameController.text.isNotEmpty &&
                    keyController.text.isNotEmpty) {
                  project.name = nameController.text;
                  project.key = keyController.text.toUpperCase();
                  project.description = descController.text.isNotEmpty
                      ? descController.text
                      : null;
                  project.color = selectedColor;
                  context.read<TaskService>().updateProject(project);
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

  void _confirmDeleteProject(Project project) {
    final taskCount =
        context.read<TaskService>().getTasksForProject(project.id).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? '
          '${taskCount > 0 ? 'This will also delete $taskCount task${taskCount > 1 ? 's' : ''} in this project. ' : ''}'
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

  String _generateKey(String name) {
    if (name.isEmpty) return '';
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 3)).toUpperCase();
    }
    return words.map((w) => w[0]).take(3).join().toUpperCase();
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
