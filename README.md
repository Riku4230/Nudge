# ReminderMenu

macOS メニューバー常駐の Apple リマインダー連携アプリです。EventKit で純正リマインダーを読み書きし、iCloud 経由で iPhone/iPad/Mac と同期します。

## ビルド

```bash
./scripts/build_app.sh
```

生成先:

```text
build/ReminderMenu.app
```

要件どおり `~/Applications` に配置する場合:

```bash
./scripts/build_app.sh --install
```

## 起動

```bash
open ~/Applications/ReminderMenu.app
```

初回起動時にリマインダーへのフルアクセス許可が必要です。

## 実装済み

- メニューバー常駐、Dock 非表示、transient ポップオーバー
- Glass Float デザインの SwiftUI 実装
- ライト/ダーク/システム追従の外観切替
- 今日 / 予定 / すべて / 重要のスマートリスト
- iCloud/ローカルのユーザーリスト表示、新規リスト作成
- 検索、期限順/優先度順/タイトル順ソート
- リマインダー追加、編集、削除、完了/未完了
- 完了済み表示切替、完了済み一括削除
- 任意のグローバルショートカット登録
- AI モード: `claude -p` JSON パース、失敗時はローカル日本語パーサーへフォールバック
- AI/通常追加後の「追加しました」トースト表示
