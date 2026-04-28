# Changelog

All notable changes to Hutch are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/).

For per-release binaries and SHA256 checksums, see
[GitHub Releases](https://github.com/Riku4230/Hutch/releases).

## [Unreleased]

## [0.2.1] - 2026-04-28

### Changed
- リリース説明文に共通テンプレ（install / SHA256 検証 / セキュリティ概要）を自動挿入するよう Release workflow を更新。
- README / SECURITY のインストール導線を「ソースからのビルドが推奨、未署名 dmg / Homebrew Cask は上級者向け」に整理。
- README に SHA256 チェックサム検証手順を追加。
- 「Homebrew（推奨）」ラベルを撤去し、Gatekeeper 警告に関する案内を `<details>` で折り畳み。

## [0.2.0] - 2026-04-28

### Added
- **リブランディング**: ReminderMenu / Nudge → **Hutch** に名称変更。Bundle ID は `dev.remindermenu.app` のまま据え置き、既存ユーザーの権限・Keychain キーを引き継ぎ。
- **オンボーディングウィザード**: 初回起動時に 4 ステップ（リマインダー許可 → Shortcut 取り込み → FDA → AI プロバイダー）で案内。`@AppStorage` で進行状態を永続化し、FDA 許可による自動再起動後も続きから再開。
- **マルチプロバイダー AI**: Claude Code (CLI) / Anthropic / OpenAI / Gemini を切替可能に。API キーは macOS Keychain で保管。
- **AI サブタスク自動分解**: 親タスクから 3〜7 件のサブタスクを Claude が提案、編集して一括登録。
- **カレンダービュー**: 月グリッドにリマインダーをリスト色のドット表示。日本の祝日対応、選択日タップで該当タスク + 期日なしセクションを下部表示。
- **進行中ステータス**: チェックボックスを 3 状態化（未着手 / 進行中 / 完了）。`#wip` タグで iCloud 同期。
- **メニューバー脈動通知**: アラーム時刻にアイコンが短時間アニメ。常時表示の数字バッジは置かない。
- **Shift+Enter で改行**: AI モード入力欄で複数行プロンプトに対応。
- **配布インフラ**: GitHub Releases に `.dmg` 自動公開、Homebrew Cask の version / SHA256 を main に自動 push、`.github/release_template.md` で説明文を統一。

### Changed
- ダークモード対応を整理（adaptive Color、ガラスマテリアルの暗色版、サブメニューも `NSApp.appearance` で同期）。
- 進行中アイコンを「常時回転スピナー」から「状態変更時に 1 周だけ回って静止」へ変更（リスト内でアニメが視覚ノイズになる問題を解消）。
- ポップオーバーの角に NSPopover の地が透ける問題を、`NSHostingController` 側のレイヤークリップで修正。

### Fixed
- CI（macOS 14 + Xcode 15.4）で `CalendarView.DayCell.dotColor` と `ReminderStore.startPulseTimer` が Swift concurrency エラーを起こす問題を修正。

## [0.1.0] - 2026-04-28

### Added
- 初回リリース。
- メニューバー常駐 + Glass Float SwiftUI ポップオーバー。
- EventKit 経由で純正リマインダーを読み書き、iCloud 同期。
- スマートリスト（今日 / 予定 / すべて / フラグあり）と検索・ソート。
- リマインダーの追加・編集・削除・完了切替、完了済み一括削除。
- サブタスク追加（Shortcuts.app 経由）+ 階層表示（Reminders SQLite read-only）。
- AI モード初期実装（自然言語からの追加）。
- グローバルショートカット登録機能。

[Unreleased]: https://github.com/Riku4230/Hutch/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/Riku4230/Hutch/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/Riku4230/Hutch/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Riku4230/Hutch/releases/tag/v0.1.0
