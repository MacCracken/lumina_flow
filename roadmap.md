# Photis Nadi Roadmap

## Overview
Cross-platform productivity app combining Kanban-style task management with daily ritual tracking. Built with Flutter.

---

## Completed ✓

### v2026.3.1
- Task Dependencies: Blocked-by relationships, visual indicators, drag warnings
- Keyboard Shortcuts: Ctrl+N (quick add), Ctrl+K (search), Escape
- Integration tests for task dependencies (67 tests total)

### v2026.2.22
- Extracted reusable UI components

### v2026.2.16
- Model validation & error handling
- Pagination for Kanban columns
- Comprehensive test suite (55 tests)
- Code organization & cleanup

---

## In Progress

---

## Planned Features

### High Priority

1. ~~Search & Filter~~
   - ~~Global task search across projects~~
   - ~~Filter by tags, priority, due date~~
   - ~~Sort options (date, priority, alphabetical)~~

2. ~~Task Dependencies~~
   - ~~Blocked-by relationships~~
   - ~~Visual dependency indicators~~
   - ~~Dependency warnings on drag~~

3. ~~Keyboard Shortcuts~~
   - ~~Desktop: vim-like navigation~~
   - ~~Quick task creation (Ctrl+N)~~
   - ~~Quick search (Ctrl+K)~~

### Medium Priority

4. **Supabase Sync**
   - Cloud backup & restore
   - Cross-device sync
   - Conflict resolution UI

5. **Tags System**
   - Create/edit/delete tags
   - Tag colors
   - Filter by multiple tags

6. **Due Date Notifications**
   - Desktop notifications
   - Overdue reminders
   - Due today indicators

7. **Multiple Boards per Project**
   - Board templates
   - Board switching

### Low Priority

8. **Theme Customization**
   - Custom accent colors
   - Compact/comfortable mode

9. **Keyboard Navigation**
   - Tab through tasks
   - Enter to open, Escape to close

10. **Export/Import**
    - JSON export
    - CSV export for tasks

---

## Technical Improvements

### Tech Debt
- [ ] Refactor KanbanBoard to use smaller components
- [ ] Add integration tests
- [ ] Add widget tests for UI components
- [ ] Performance profiling for large datasets

### Architecture
- [ ] Consider BLoC pattern for complex state
- [ ] Repository pattern for data access
- [ ] Dependency injection setup

---

## Backlog (Future)

- Markdown support in task descriptions
- File attachments
- Subtasks/checklists
- Time tracking
- Recurring tasks
- Team sharing (multi-user)
- Web platform support
