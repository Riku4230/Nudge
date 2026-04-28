# Hutch への貢献ガイド

PR / Issue 大歓迎です。小さな typo 修正から大きな機能追加まで、無理のない範囲で気軽に投げてください。

このドキュメントは「どう貢献すれば取り込みやすいか」をまとめたもの。最初は細かいルールを覚えなくて大丈夫です。

---

## 目次

- [前提環境](#前提環境)
- [開発の始め方](#開発の始め方)
- [コードの作法](#コードの作法)
- [PR の作り方](#pr-の作り方)
- [Issue の書き方](#issue-の書き方)
- [リリース手順（メンテナ向け）](#リリース手順メンテナ向け)
- [コミュニケーション](#コミュニケーション)

---

## 前提環境

- macOS 14（Sonoma）以降
- Xcode コマンドラインツール（または Xcode 本体）
- Swift 5.9 以降
- 純正リマインダー / iCloud アカウント（動作確認用）

任意:

- Claude Code CLI / Anthropic / OpenAI / Gemini のいずれか（AI モード検証用）

---

## 開発の始め方

```bash
git clone https://github.com/Riku4230/Hutch.git
cd Hutch

# デバッグビルド（高速）
swift build

# リリースビルド + ~/Applications に配置（実機検証）
./scripts/build_app.sh --install

# 起動中のプロセスを kill して再起動
pkill -f Hutch.app && open ~/Applications/Hutch.app
```

依存関係はゼロ。Swift Package Manager だけでビルドできます。

### デモモードで起動する

スクリーンショットや録画で **自分の実タスクを映したくない** 時は `HUTCH_DEMO=1` を env var に渡して起動するとダミーデータで動きます。EventKit には一切書き込まないので安全です。

```bash
HUTCH_DEMO=1 open ~/Applications/Hutch.app
```

または恒久的に：

```bash
defaults write dev.remindermenu.app HUTCH_DEMO -bool true
open ~/Applications/Hutch.app
# 解除
defaults delete dev.remindermenu.app HUTCH_DEMO
```

ヘッダー左に **DEMO** バッジが出ている間は、すべての操作が in-memory のみで実データに影響しません。

### よくあるトラブル

- **「リマインダーへのアクセスが許可されていません」**: 初回ダイアログで許可するか、システム設定 → プライバシーとセキュリティ → リマインダーで Hutch を ON
- **サブタスクの階層表示が出ない**: フルディスクアクセス未許可。システム設定 → プライバシーとセキュリティ → フルディスクアクセスで Hutch を ON
- **AI モードが動かない**: 「⋯ → AI 設定」でプロバイダー選択 + API キー入力（Claude Code CLI 利用なら不要）

---

## コードの作法

最低限以下を守ってもらえると、レビューがスムーズです。

### Swift

- SwiftUI / EventKit ベース。AppKit は menu bar / NSPopover 周りでだけ使う
- `@MainActor` を意識する。`ReminderStore` は MainActor isolated
- `@Published` で状態管理、`Combine` の Subject は最小限に
- `Process` を起動するときは `arguments` 配列で渡す（シェル経由は禁止）
- API キーや認証情報は **必ず Keychain**（`KeychainStore.swift`）。UserDefaults / 平文ファイル禁止
- 純正リマインダーの SQLite を触る場合は **read-only + スナップショットコピー**（`RemindersSQLite.swift` の `snapshotDatabase` を経由）

### コミットメッセージ

Conventional Commits 風が望ましいですが、必須ではありません。

```
Add AI subtask generation with confirmation popover
Fix Swift 6 concurrency errors in CI build
Polish onboarding nav buttons and warn about FDA restart
```

長めの説明が欲しい時は本文を改行で区切って続けて OK。

### ファイル構成

```
ReminderMenu/
  ReminderStore.swift       # EventKit 読み書き、進行中ステータス、サブタスク統合
  RemindersSQLite.swift     # 純正 DB から親子マップ抽出（read-only）
  ShortcutsBridge.swift     # `shortcuts run` の Swift ラッパー
  AIProvider.swift          # LLM プロバイダー抽象
  Providers/                # 各プロバイダー実装（Claude / Anthropic / OpenAI / Gemini）
  NLParser.swift            # 自然言語 → ReminderDraft / サブタスク候補
  Holidays.swift            # 日本の祝日ルール計算
  MainView.swift            # メニューバーポップオーバー全体
  ReminderRow.swift         # 個別リマインダー行
  CalendarView.swift        # 月カレンダービュー
  OnboardingView.swift      # 初回起動ウィザード
  AISettingsSheet.swift     # AI 設定シート
  Theme.swift               # 色 / 角丸 / 余白の Design Token
  MRComponents.swift        # 共通 UI 部品
```

新しい機能を追加する時は、上の分担に近いファイルに追加するか、新規ファイルとして切り出してください。

---

## PR の作り方

1. main から feature branch を切る（例: `feat/some-feature`、`fix/some-bug`、`docs/some-doc`）
2. 変更を加えてビルドが通ることを確認
3. `./scripts/build_app.sh --install` で実機検証
4. README / CHANGELOG / SECURITY.md など影響するドキュメントを更新
5. Push して GitHub で PR 作成

### PR の説明に含めると嬉しいもの

- 何を変えたか（1〜3 行）
- なぜ変えたか（背景やトリガーになった出来事）
- 動作確認したシナリオ（ビルド / 起動 / 実機操作）
- スクリーンショット（UI 変更時）

### 言語

README / コードコメント / コミットメッセージ / PR 説明は **日本語ベース** で OK です。英語ユーザー向けには `README.en.md` を併記しているので、新機能で英語 README にも反映できそうな場合は触ってもらえると助かります（必須ではない）。

### マージ方針

- 基本は **squash merge**
- main は branch protection（1 reviewer 必須、admin bypass あり）
- メンテナレビューは早めに返すように頑張ります

---

## Issue の書き方

### バグ報告

以下が揃っていると修正が早いです：

- macOS のバージョン（System Information → ソフトウェア概要）
- Hutch のバージョン（「⋯」メニュー末尾に表示予定）
- 再現手順
- 期待される挙動 / 実際の挙動
- スクリーンショット / 動画があれば

### 機能要望

- どんな課題を解決したいか
- 既存機能で代用できないか確認した結果
- 似たアプリで参考になる実装があれば

---

## リリース手順（メンテナ向け）

```bash
# main を最新に
git checkout main && git pull

# 必要なら CHANGELOG.md の [Unreleased] を [vX.Y.Z] に rename
# git add CHANGELOG.md && git commit -m "Bump CHANGELOG to vX.Y.Z"

# タグを切って push
git tag vX.Y.Z
git push origin vX.Y.Z
```

GitHub Actions が以下を自動で実行：

1. macOS 14 でビルド（Info.plist の version を tag から差し込み）
2. `Hutch-vX.Y.Z.dmg` 生成 + SHA256 計算
3. GitHub Release 作成（`.github/release_template.md` + 自動 changelog）
4. `Casks/hutch.rb` の version / sha256 を main に `[skip ci]` で push

`RELEASE_TOKEN` secret（オーナーの fine-grained PAT）を使って branch protection を bypass します。

### Cask が更新されない場合

- `.github/workflows/release.yml` の `Update Homebrew Cask on main` ステップが失敗していないか確認
- `RELEASE_TOKEN` の有効期限切れの可能性
- 手動で `Casks/hutch.rb` の version / sha256 を更新する

### Apple Developer ID への移行

Developer Program 加入後、`scripts/build_app.sh` の codesign + `xcrun notarytool` ステップを差し替える予定。詳細は別 Issue で。

---

## コミュニケーション

- バグ報告・機能要望: [GitHub Issues](https://github.com/Riku4230/Hutch/issues)
- セキュリティ脆弱性: [SECURITY.md](SECURITY.md) 参照（GitHub Security Advisories）
- それ以外の雑談・質問: Issue で気軽に

最後に、Hutch は個人プロジェクトとして始まった OSS です。完璧を求めすぎないのがコツ。気軽に PR / Issue お願いします。
