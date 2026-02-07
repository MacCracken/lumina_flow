# Lumina Flow Usage Guide

This guide explains how to use Lumina Flow for daily productivity and task management.

## Table of Contents

- [Getting Started](#getting-started)
- [Kanban Board](#kanban-board)
- [Daily Rituals](#daily-rituals)
- [Theme Modes](#theme-modes)
- [Desktop Features](#desktop-features)
- [Data Management](#data-management)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Troubleshooting](#troubleshooting)

## Getting Started

### First Launch

When you open Lumina Flow for the first time:

1. **Welcome Screen**: The app initializes with a default "My Projects" Kanban board
2. **Empty State**: Both the Kanban board and Rituals sidebar start empty
3. **Local Storage**: All data is stored locally on your device - no internet required

### Quick Setup (5 Minutes)

1. **Add Your First Ritual**: Click the + icon in the Rituals sidebar
2. **Create Your First Task**: Use the floating + button on the main screen
3. **Explore Themes**: Click the palette icon to toggle between Vibrant and E-Reader modes

### Understanding the Interface

```
┌─────────────────────────────────────────────────────────────┐
│ [🏠 Lumina Flow]                    [🎨 Palette]      │
├──────────────┬────────────────────────────────────────────┤
│              │                                            │
│   🔄 Rituals │         📋 Kanban Board                   │
│   Sidebar    │                                            │
│              │  ┌─────┐  ┌─────────┐  ┌─────┐           │
│   ☐ Wake Up  │  │ To  │  │ In      │  │Done │           │
│   ☐ Meditate │  │ Do  │  │Progress │  │     │           │
│   ☐ Exercise │  └─────┘  └─────────┘  └─────┘           │
│              │                                            │
└──────────────┴─────────────────────────────────────────────┘
```

## Kanban Board

The Kanban board helps you organize tasks across different stages of completion.

### Adding Tasks

#### Quick Add (Floating Button)
1. Click the **+** floating button at bottom right
2. Select **"Add Task"**
3. Enter title and optionally description
4. Set priority (Low/Medium/High)
5. Click **"Add"**

#### Column-Specific Add
1. Click **"Add Task"** button at bottom of any column
2. Task will be added directly to that column

### Managing Tasks

#### Moving Tasks Between Columns
- **Desktop**: Drag and drop tasks between columns
- **Mobile**: Long press task, select "Move", choose destination column
- **Menu**: Click task → "Move to Column"

#### Task Properties
- **Priority Colors**: 
  - 🔴 Red = High priority
  - 🟠 Orange = Medium priority  
  - 🟢 Green = Low priority
- **Due Dates**: Visible in task details when set
- **Status**: Determined by which column the task is in

#### Editing Tasks
1. Click on any task to view details
2. In the details dialog, you can:
   - Edit title and description
   - Change priority
   - Set due date
   - Add tags
3. Changes save automatically

#### Deleting Tasks
1. Long press on task (mobile) or right-click (desktop)
2. Select **"Delete"**
3. Confirm deletion
   - **Note**: Deleted tasks cannot be recovered

### Board Columns

#### Default Columns
- **To Do**: New tasks and backlog items
- **In Progress**: Currently working on
- **Done**: Completed tasks

#### Column Operations
- **View Tasks**: Scroll horizontally to see all columns
- **Add Tasks**: Use + button at bottom of each column
- **View Progress**: See task count and status per column

## Daily Rituals

The Rituals sidebar helps you maintain daily habits and routines.

### Adding Rituals

1. Click **+** icon in Rituals sidebar header
2. Fill in the ritual details:
   - **Title** (required): e.g., "Morning Meditation"
   - **Description** (optional): Additional context
3. Click **"Add"**

### Completing Rituals

#### Mark Complete
- **Click** the circular checkbox next to any ritual
- Ritual turns green with checkmark when completed
- Streak count increases automatically

#### Mark Incomplete
- **Click** the completed ritual again to uncheck
- Streak count remains (streaks don't decrease)

#### Automatic Reset
- Rituals reset automatically at midnight
- All become unchecked for the new day
- Streak tracking continues independently

### Streak Tracking

#### Understanding Streaks
- **🔥 Fire emoji** shows current consecutive days
- **Streak increases** when you complete ritual on consecutive days
- **Streak maintains** even if you miss a day (graceful system)

#### Streak Examples
```
Completed Monday, Tuesday, Wednesday: 🔥3🔥
Missed Thursday, completed Friday: 🔥3🔥
```

### Managing Rituals

#### Sidebar Controls
- **Collapse**: Click ← arrow to minimize sidebar (shows icons only)
- **Expand**: Click → arrow to restore full sidebar
- **Progress Bar**: Shows completion percentage for the day

#### Ritual Operations
- **Edit**: Click three dots (⋮) next to ritual → "Edit"
- **Delete**: Click three dots (⋯) next to ritual → "Delete"

## Theme Modes

Lumina Flow offers two distinct visual modes for different use cases.

### Vibrant Mode (Default)
- **Glassmorphism**: Frosted glass effects with transparency
- **Color Palette**: Deep indigos, soft teals, accent oranges
- **Best For**: Everyday use on modern displays
- **Features**: 
  - Smooth animations
  - Subtle shadows and gradients
  - Full color experience

### E-Reader Mode
- **High Contrast**: Pure black and white (1-bit style)
- **Bold Borders**: 2px+ borders instead of colors
- **Best For**: 
  - E-ink displays (reMarkable, Kindle Scribe)
  - Low-light environments
  - Users with visual impairments
- **Features**:
  - No animations or transitions
  - Increased font weights
  - Maximum readability

### Switching Modes
1. Click **🎨 Palette** icon in top-right corner
2. Select **"E-Reader Mode"** to toggle
3. Mode preference is saved automatically
4. Instant switch - no app restart needed

### Mode Comparison

| Feature | Vibrant Mode | E-Reader Mode |
|---------|--------------|---------------|
| Colors | Full palette | Black & White |
| Animations | Enabled | Disabled |
| Borders | Subtle | Bold (2px+) |
| Shadows | Enabled | Disabled |
| Font Weight | Normal | Bold |
| Battery Use | Higher | Lower |

## Desktop Features

Lumina Flow includes special integrations for desktop operating systems.

### macOS Features

#### Menu Bar Integration
- **Quick Access**: Access Lumina Flow from menu bar
- **Window Controls**: Show/hide, minimize to tray
- **Status**: See task and ritual completion status

#### Always-on-Top Mode
- **Floating Window**: Keep app visible above other windows
- **Use Case**: Reference tasks while working in other apps
- **Activation**: 
  1. System tray → "Always on Top"
  2. Or use window controls

#### System Tray
- **Background Operation**: Keep running minimized
- **Quick Actions**: Add tasks, complete rituals from tray
- **Startup**: Option to launch at system startup

### Linux Features

#### AppImage Support
- **Portable**: Run without installation
- **Self-contained**: All dependencies included
- **Usage**: 
  ```bash
  chmod +x LuminaFlow.AppImage
  ./LuminaFlow.AppImage
  ```

#### Flatpak Ready
- **Sandboxed**: Secure, isolated installation
- **Distribution**: Easy install across Linux distributions
- **Updates**: Automatic updates through Flatpak

#### Desktop Integration
- **Application Menu**: Appears in app launcher
- **File Associations**: Opens task/ritual files if exported
- **Notifications**: System notifications for important events

### Cross-Platform Desktop Features

#### Window Management
- **Resizing**: Drag edges to resize
- **Maximize**: Full screen or half-screen
- **Keyboard Shortcuts**: Alt+F4 to close, etc.

#### System Notifications
- **Task Reminders**: Due date notifications
- **Ritual Reminders**: Daily ritual prompts
- **Sync Status**: When cloud sync completes

## Data Management

### Local Storage

#### Data Location
- **macOS**: `~/Library/Application Support/lumina_flow/`
- **Linux**: `~/.local/share/lumina_flow/`
- **Windows**: `%APPDATA%/lumina_flow/`

#### Data Files
- **tasks.db**: Local Hive database for tasks
- **rituals.db**: Rituals and streak data
- **settings.json**: User preferences and themes
- **sync_cache**: Temporary sync data (if using cloud sync)

### Backup Recommendations

#### Manual Backup
1. **Close Lumina Flow** completely
2. **Navigate** to data location (see above)
3. **Copy entire folder** to backup location
4. **Schedule regular backups** (weekly recommended)

#### Automated Backup
- **Time Machine** (macOS): Automatically included if enabled
- **rsync** (Linux): `rsync -av ~/.local/share/lumina_flow/ backup/`
- **Cloud Storage**: Sync data folder to Dropbox/Google Drive

### Sync Setup (Cloud Sync)

#### Prerequisites
- Supabase account and project
- Internet connection
- Lumina Flow Pro (when available)

#### Setup Process
1. **Open Settings** → "Sync Configuration"
2. **Enter Supabase URL** and **API Key**
3. **Test Connection**
4. **Enable Sync**
5. **Choose sync frequency**: Real-time, hourly, manual

#### Sync Behavior
- **Local-First**: Works offline, syncs when online
- **Conflict Resolution**: Last-write-wins for simple conflicts
- **Privacy**: All data encrypted in transit and at rest

### Data Export/Import

#### Export Data
1. **Settings** → "Data Management" → "Export"
2. **Choose format**: JSON, CSV
3. **Select data**: Tasks only, Rituals only, or All
4. **Save to file**

#### Import Data
1. **Settings** → "Data Management" → "Import"
2. **Select file**: Choose exported file
3. **Merge options**: 
   - **Replace**: Clear existing data
   - **Merge**: Combine with existing data
4. **Confirm import**

## Keyboard Shortcuts

### Global Shortcuts (All Platforms)

| Shortcut | Action | Platform |
|----------|--------|----------|
| `Ctrl/Cmd + N` | New Task | All |
| `Ctrl/Cmd + R` | New Ritual | All |
| `Ctrl/Cmd + ,` | Settings | All |
| `Ctrl/Cmd + Q` | Quit | All |
| `F11` | Toggle Fullscreen | All |
| `Ctrl/Cmd + T` | Toggle Theme | All |

### Navigation Shortcuts

| Shortcut | Action | Context |
|----------|--------|---------|
| `Tab` | Next element | Forms |
| `Shift + Tab` | Previous element | Forms |
| `Enter` | Confirm/Submit | Forms |
| `Escape` | Cancel/Close | Dialogs |
| `Space` | Toggle checkbox | Rituals |

### Kanban Board Shortcuts

| Shortcut | Action | Context |
|----------|--------|---------|
| `→` | Next column | Board |
| `←` | Previous column | Board |
| `↓` | Next task | Column |
| `↑` | Previous task | Column |
| `Delete` | Delete selected task | Task selected |

### macOS Specific

| Shortcut | Action |
|----------|--------|
| `Cmd + ,` | Preferences |
| `Cmd + H` | Hide Window |
| `Cmd + M` | Minimize |
| `Cmd + Option + H` | Hide Others |
| `Cmd + Q` | Quit |

### Linux Specific

| Shortcut | Action |
|----------|--------|
| `Alt + F4` | Close Window |
| `F10` | Menu Bar |
| `Ctrl + PageUp` | Previous Column |
| `Ctrl + PageDown` | Next Column |

## Troubleshooting

### Common Issues

#### App Won't Start

**Symptoms**: App crashes on launch or shows blank screen

**Solutions**:
1. **Check Flutter Version**: Ensure Flutter 3.10+ installed
2. **Clear Cache**: 
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Check Permissions**: Ensure app has file system access
4. **Restart Device**: Simple but often effective

#### Tasks Not Saving

**Symptoms**: Added tasks disappear when app restarts

**Solutions**:
1. **Check Disk Space**: Ensure sufficient storage available
2. **File Permissions**: Verify write access to app data directory
3. **Database Corruption**: Delete database files (will lose data)
4. **Update App**: Install latest version

#### Sync Not Working

**Symptoms**: Cloud sync failing or not updating

**Solutions**:
1. **Check Internet**: Verify network connectivity
2. **API Keys**: Ensure Supabase credentials correct
3. **Firewall**: Check if network access blocked
4. **Server Status**: Verify Supabase services operational

#### Performance Issues

**Symptoms**: App running slowly or lagging

**Solutions**:
1. **Large Database**: Archive old tasks and rituals
2. **Memory**: Check system memory usage
3. **Graphics**: Update graphics drivers (desktop)
4. **Device Age**: Consider device capabilities

### Performance Tips

#### Optimize for Speed
1. **Limit Active Tasks**: Keep under 100 active tasks per column
2. **Archive Completed**: Regularly move old tasks to archive
3. **Simplify Rituals**: Keep under 20 active rituals
4. **Use E-Reader Mode**: Reduces GPU usage

#### Optimize for Battery
1. **Disable Animations**: Use E-Reader mode on laptops
2. **Reduce Sync Frequency**: Change from real-time to hourly
3. **Close Background**: Quit when not actively using
4. **Dark Mode**: Use dark theme on OLED screens

### Compatibility

#### Operating System Requirements
- **macOS**: 13.7.8+ (Ventura/Sonoma)
- **Linux**: Ubuntu 20.04+, Fedora 35+, Arch Linux
- **Windows**: Windows 10+ (when implemented)
- **iOS**: iOS 15+ (when implemented)
- **Android**: Android 8+ (when implemented)

#### Hardware Requirements
- **Minimum RAM**: 4GB
- **Storage**: 500MB free space
- **Display**: 1024x768 minimum resolution
- **Processor**: ARM64 or x86_64

### Getting Help

#### Community Support
- **GitHub Issues**: Report bugs and feature requests
- **Discord Community**: Real-time chat with other users
- **Documentation**: Updated regularly with new features

#### Bug Reporting
When reporting issues, include:
1. **Operating System**: Version and build
2. **App Version**: Current Lumina Flow version
3. **Reproduction Steps**: Clear, numbered steps to reproduce
4. **Expected vs Actual**: What should happen vs what does happen
5. **Console Output**: Any error messages or logs

#### Feature Requests
We welcome feature suggestions:
1. **Use Cases**: Explain the problem you're trying to solve
2. **Proposed Solution**: Your idea for addressing it
3. **Alternatives**: Other approaches you've considered
4. **Impact**: How this would improve your workflow

---

For technical documentation and development information, see the main [README.md](README.md) file.