import 'package:flutter/material.dart';
import '../../common/utils.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;
  final List<String>? colors;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.colors,
  });

  static const List<String> defaultColors = [
    '#6B7280',
    '#3B82F6',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#8B5CF6',
    '#EC4899',
  ];

  @override
  Widget build(BuildContext context) {
    final colorList = colors ?? defaultColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colorList.map((colorHex) {
        final color = parseColor(colorHex);
        final isSelected = selectedColor == colorHex;
        return GestureDetector(
          onTap: () => onColorSelected(colorHex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(color: Colors.black, width: 2) : null,
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
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ColorBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double? fontSize;
  final EdgeInsets? padding;

  const ColorBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class StreakBadge extends StatelessWidget {
  final int streakCount;

  const StreakBadge({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    if (streakCount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$streakCount🔥',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const CountBadge({
    super.key,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class SidebarHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Widget? leading;

  const SidebarHeader({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.actionIcon,
    this.onAction,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return SizedBox(
        height: 60,
        child: leading ??
            Center(
              child: IconButton(
                onPressed: onToggleCollapse,
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
            onPressed: onToggleCollapse,
            icon: const Icon(Icons.keyboard_double_arrow_left),
            tooltip: 'Collapse',
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actionIcon != null && onAction != null)
            IconButton(
              onPressed: onAction,
              icon: Icon(actionIcon),
            ),
        ],
      ),
    );
  }
}

class CollapsibleSidebar extends StatelessWidget {
  final bool isCollapsed;
  final double collapsedWidth;
  final double expandedWidth;
  final Widget header;
  final Widget child;

  const CollapsibleSidebar({
    super.key,
    required this.isCollapsed,
    this.collapsedWidth = 60,
    this.expandedWidth = 240,
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? collapsedWidth : expandedWidth,
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
          header,
          Expanded(child: child),
        ],
      ),
    );
  }
}

class CollapsedListItem extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? tooltip;

  const CollapsedListItem({
    super.key,
    required this.label,
    this.color,
    this.isSelected = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.grey;
    final item = Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? displayColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? displayColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label.length > 2 ? label.substring(0, 2) : label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: item,
      );
    }
    return item;
  }
}

class ActionMenuItem extends StatelessWidget {
  final String value;
  final IconData icon;
  final String label;
  final Color? iconColor;

  const ActionMenuItem({
    super.key,
    required this.value,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class EditDeleteMenu extends StatelessWidget {
  final void Function(String) onSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDeleteDestructive;

  const EditDeleteMenu({
    super.key,
    required this.onSelected,
    this.onEdit,
    this.onDelete,
    this.isDeleteDestructive = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        if (onEdit != null)
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
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  size: 18,
                  color: isDeleteDestructive ? Colors.red : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: isDeleteDestructive
                      ? const TextStyle(color: Colors.red)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
