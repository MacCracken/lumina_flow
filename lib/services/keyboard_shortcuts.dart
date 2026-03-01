import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts {
  static final Map<ShortcutActivator, Intent> shortcuts = {
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        const AddTaskIntent(),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        const FocusSearchIntent(),
    const SingleActivator(LogicalKeyboardKey.keyF, control: true):
        const FocusSearchIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const EscapeIntent(),
  };
}

class AddTaskIntent extends Intent {
  const AddTaskIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onAddTask;
  final VoidCallback? onFocusSearch;
  final VoidCallback? onEscape;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onAddTask,
    this.onFocusSearch,
    this.onEscape,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.shortcuts,
      child: Actions(
        actions: {
          AddTaskIntent: CallbackAction<AddTaskIntent>(
            onInvoke: (_) {
              onAddTask?.call();
              return null;
            },
          ),
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (_) {
              onFocusSearch?.call();
              return null;
            },
          ),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (_) {
              onEscape?.call();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
