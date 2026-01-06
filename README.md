# MenuBarRecorder

A simple, lightweight macOS Menu Bar application for recording voice memos.

## Features

- **Menu Bar Access**: Runs discreetly in the menu bar with a microphone icon.
- **Quick Recording**:
  - Start Recording: Click "Start Recording" or use `Cmd+S`.
  - Stop Recording: Click "Stop Recording" or use `Cmd+T`.
- **Status Indication**:
  - **■ Ready**: Not recording.
  - **● Rec** (Red): Currently recording.
- **Auto-Saving**: Recordings are automatically saved as AAC (`.m4a`) files in `~/Documents/VoiceMemos/`.
  - Filenames include the date and time (e.g., `Recording_2025-01-01_12-00-00.m4a`).
- **Open Folder**: Quickly access your recordings via the "Open Voice Memos Folder" menu item.

## Requirements

- macOS
- Xcode Command Line Tools (installed via `xcode-select --install`)

## Build & Run

This project uses **Objective-C** to ensure maximum compatibility with various macOS SDK versions and Command Line Tools configurations, avoiding common Swift Standard Library version mismatch issues.

### 1. Build
Open your terminal and run:

```bash
make
```

### 2. Run
Once built, you can launch the app directly:

```bash
open MenuBarRecorder.app
```

### 3. Clean
To remove build artifacts:

```bash
make clean
```

## Note on First Launch
When you first record audio, macOS will prompt you to grant microphone access to the application. Please select **OK** to allow recording.
