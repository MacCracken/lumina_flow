import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../services/theme_service.dart';
import '../services/keyboard_shortcuts.dart';
import '../widgets/kanban_board.dart';
import '../widgets/project_sidebar.dart';
import '../widgets/rituals_sidebar.dart';
import '../widgets/theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProjectsCollapsed = false;
  bool _isRitualsCollapsed = false;
  int _selectedNavIndex = 1;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().init();
      context.read<ThemeService>().loadPreferences();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool get _isWideScreen => MediaQuery.of(context).size.width > 800;

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text('Add Task'),
            onTap: () {
              Navigator.pop(context);
              _showAddTaskDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Add Ritual'),
            onTap: () {
              Navigator.pop(context);
              _showAddRitualDialog();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TaskService>().addTask(
                      titleController.text,
                      description: descController.text.isNotEmpty
                          ? descController.text
                          : null,
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      descController.dispose();
    });
  }

  void _showAddRitualDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Ritual'),
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
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TaskService>().addRitual(
                      titleController.text,
                      description: descController.text.isNotEmpty
                          ? descController.text
                          : null,
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      descController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsWrapper(
      onAddTask: _showAddTaskDialog,
      onFocusSearch: () {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      },
      onEscape: () {
        FocusScope.of(context).unfocus();
      },
      child: Builder(
        builder: (context) => Selector<TaskService, bool>(
          selector: (_, service) => service.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              );
            }

            return Selector<TaskService, String?>(
              selector: (_, service) => service.error,
              builder: (context, error, _) {
                if (error != null) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(error, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TaskService>().clearError();
                              context.read<TaskService>().init();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_isWideScreen) {
                  return _buildWideLayout();
                }
                return _buildNarrowLayout();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photis Nadi'),
        actions: const [
          ThemeToggle(),
        ],
      ),
      body: Row(
        children: [
          ProjectSidebar(
            isCollapsed: _isProjectsCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isProjectsCollapsed = !_isProjectsCollapsed;
              });
            },
          ),
          const Expanded(
            child: KanbanBoard(),
          ),
          RitualsSidebar(
            isCollapsed: _isRitualsCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isRitualsCollapsed = !_isRitualsCollapsed;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddMenu,
        tooltip: 'Quick Add (Ctrl+N)',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photis Nadi'),
        actions: const [
          ThemeToggle(),
        ],
      ),
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          ProjectSidebar(isCollapsed: false, onToggleCollapse: () {}),
          const KanbanBoard(),
          RitualsSidebar(isCollapsed: false, onToggleCollapse: () {}),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_kanban_outlined),
            selectedIcon: Icon(Icons.view_kanban),
            label: 'Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat_outlined),
            selectedIcon: Icon(Icons.repeat),
            label: 'Rituals',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddMenu,
        tooltip: 'Quick Add (Ctrl+N)',
        child: const Icon(Icons.add),
      ),
    );
  }
}
