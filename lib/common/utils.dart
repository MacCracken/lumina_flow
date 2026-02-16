import 'package:flutter/material.dart';
import '../models/task.dart';

/// Validates a hex color string
bool isValidHexColor(String colorHex) {
  if (colorHex.isEmpty) return false;
  final hexPattern = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
  return hexPattern.hasMatch(colorHex);
}

/// Normalizes a hex color string to #RRGGBB format
String normalizeHexColor(String colorHex) {
  String normalized = colorHex.trim().toUpperCase();
  if (!normalized.startsWith('#')) {
    normalized = '#$normalized';
  }
  return normalized;
}

/// Validates a project key (2-5 uppercase alphanumeric characters)
bool isValidProjectKey(String key) {
  if (key.isEmpty) return false;
  final keyPattern = RegExp(r'^[A-Z0-9]{2,5}$');
  return keyPattern.hasMatch(key);
}

/// Validates a UUID string
bool isValidUuid(String uuid) {
  final uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  return uuidPattern.hasMatch(uuid);
}

/// Parses a hex color string to a Color object
Color parseColor(String colorHex) {
  try {
    final normalized = normalizeHexColor(colorHex);
    return Color(int.parse(normalized.replaceFirst('#', '0x')));
  } on FormatException {
    return Colors.blue;
  }
}

/// Formats a DateTime to a string (DD/MM/YYYY)
String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

/// Capitalizes the first letter of a string
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Formats a TaskPriority to a display string
String formatPriority(TaskPriority priority) => capitalizeFirst(priority.name);

/// Formats a TaskStatus to a display string
String formatStatus(TaskStatus status) =>
    capitalizeFirst(status.name.replaceAll('_', ' '));

/// Gets the color for a task priority
Color getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red;
    case TaskPriority.medium:
      return Colors.orange;
    case TaskPriority.low:
      return Colors.green;
  }
}

/// Generates a project key from a project name
String generateProjectKey(String name) {
  if (name.isEmpty) return '';
  final words = name.split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length == 1) {
    return words[0].substring(0, words[0].length.clamp(0, 3)).toUpperCase();
  }
  return words.map((w) => w[0]).take(3).join().toUpperCase();
}
