# MenuBarRecorder

A simple, lightweight macOS Menu Bar application for recording voice memos.

## Features

- **Menu Bar Access**: Runs discreetly in the menu bar with a microphone icon.
- **Quick Recording**:
  - Start Recording: Click "Start Recording" or use `Cmd+R`.
  - Stop Recording: Click "Stop Recording" or use `Cmd+R`.
- **Status Indication**:
  - A single menu bar icon is always shown.
  - The icon turns red while recording.
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

---

# (Japanese Translation)

ボイスメモを録音するためのシンプルで軽量なmacOSメニューバー常駐型アプリケーションです。

## 機能

- **メニューバー常駐**: マイクアイコンとともにメニューバーで控えめに動作します。
- **クイック録音**:
  - 録音開始: 「Start Recording」をクリックするか、`Cmd+R` を使用します。
  - 録音停止: 「Stop Recording」をクリックするか、`Cmd+R` を使用します。
- **ステータス表示**:
  - メニューバーには常に1つのアイコンのみ表示されます。
  - 録音中はアイコンが赤色に変わります。
- **自動保存**: 録音データは AAC (`.m4a`) 形式で `~/Documents/VoiceMemos/` に自動保存されます。
  - ファイル名には日時が含まれます（例: `Recording_2025-01-01_12-00-00.m4a`）。
- **フォルダを開く**: 「Open Voice Memos Folder」メニュー項目から保存先フォルダへ素早くアクセスできます。

## 必要要件

- macOS
- Xcode Command Line Tools (`xcode-select --install` でインストール可能)

## ビルドと実行

このプロジェクトは、様々なmacOS SDKバージョンやコマンドラインツール構成との互換性を最大限に確保し、一般的なSwift標準ライブラリのバージョン不整合問題を回避するために **Objective-C** を使用しています。

### 1. ビルド
ターミナルを開き、以下のコマンドを実行してください:

```bash
make
```

### 2. 実行
ビルドが完了したら、以下のコマンドでアプリを起動できます:

```bash
open MenuBarRecorder.app
```

### 3. クリーンアップ
ビルド生成物を削除するには:

```bash
make clean
```

## 初回起動時の注意
初めて録音を行う際、macOSはアプリケーションへのマイクアクセス許可を求めます。**OK** を選択して録音を許可してください。
