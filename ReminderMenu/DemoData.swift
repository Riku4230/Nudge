import AppKit
import EventKit
import Foundation

/// デモ表示用のダミーデータ生成。
///
/// 用途:
/// - README / LP / Twitter 投稿などで「自分の実タスクを映さずに」アプリの UI を見せる
/// - スクリーンショットや録画を再現性高く取りたい
///
/// 起動方法:
/// ```bash
/// HUTCH_DEMO=1 open ~/Applications/Hutch.app
/// # または
/// defaults write dev.remindermenu.app HUTCH_DEMO -bool true
/// open ~/Applications/Hutch.app
/// ```
///
/// デモモード中は EventKit への書き込みは行われず、ストアは in-memory のダミーで固定される。
/// 編集系操作（追加・削除・完了切替）は no-op になる（UI には「デモモードです」のトーストを返す）。
enum DemoMode {
    /// 環境変数または UserDefaults で有効化を検出
    static var isEnabled: Bool {
        if ProcessInfo.processInfo.environment["HUTCH_DEMO"] != nil { return true }
        return UserDefaults.standard.bool(forKey: "HUTCH_DEMO")
    }
}

/// デモ用のリマインダー / カレンダーをまとめて生成するファクトリ。
/// Hutch の UI が表示できる最小限のフィールドだけ埋める。
enum DemoData {
    /// デモデータ一式
    struct Snapshot {
        let calendars: [EKCalendar]
        let reminders: [EKReminder]
        /// childID → parentID
        let parentMap: [String: String]
    }

    @MainActor
    static func make(using eventStore: EKEventStore) -> Snapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 3 リスト（純正アプリで普通に作る感じ）
        let work = makeCalendar(title: "Work", color: NSColor.systemBlue, eventStore: eventStore)
        let personal = makeCalendar(title: "Personal", color: NSColor.systemGreen, eventStore: eventStore)
        let shopping = makeCalendar(title: "買い物", color: NSColor.systemPink, eventStore: eventStore)

        // タスク群
        var reminders: [EKReminder] = []
        var parentMap: [String: String] = [:]

        // 今日のタスク（時刻あり / なし）
        let r1 = makeReminder(
            title: "週次ミーティングの準備",
            calendar: work,
            eventStore: eventStore,
            due: setHour(today, 11, 0),
            includesTime: true
        )
        reminders.append(r1)

        let r2 = makeReminder(
            title: "メールに返信",
            calendar: work,
            eventStore: eventStore,
            due: today,
            includesTime: false
        )
        reminders.append(r2)

        // 進行中ステータス（#wip タグ付き）
        let r3 = makeReminder(
            title: "9gates 進捗まとめ",
            calendar: work,
            eventStore: eventStore,
            due: today,
            includesTime: false,
            notes: "#wip"
        )
        reminders.append(r3)

        // 明日のタスク
        let r4 = makeReminder(
            title: "歯医者",
            calendar: personal,
            eventStore: eventStore,
            due: setHour(today.addingTimeInterval(86_400), 15, 0),
            includesTime: true
        )
        reminders.append(r4)

        // 今夜
        let r5 = makeReminder(
            title: "荷物を持って帰る",
            calendar: personal,
            eventStore: eventStore,
            due: setHour(today, 19, 0),
            includesTime: true
        )
        reminders.append(r5)

        // 親 + サブタスク（買い物リスト）
        let parent = makeReminder(
            title: "買い物に行く",
            calendar: shopping,
            eventStore: eventStore,
            due: today.addingTimeInterval(86_400 * 2),
            includesTime: false
        )
        reminders.append(parent)

        let child1 = makeReminder(
            title: "牛乳",
            calendar: shopping,
            eventStore: eventStore,
            due: nil,
            includesTime: false
        )
        let child2 = makeReminder(
            title: "卵",
            calendar: shopping,
            eventStore: eventStore,
            due: nil,
            includesTime: false
        )
        let child3 = makeReminder(
            title: "コーヒー豆",
            calendar: shopping,
            eventStore: eventStore,
            due: nil,
            includesTime: false
        )
        reminders.append(contentsOf: [child1, child2, child3])
        parentMap[child1.calendarItemIdentifier] = parent.calendarItemIdentifier
        parentMap[child2.calendarItemIdentifier] = parent.calendarItemIdentifier
        parentMap[child3.calendarItemIdentifier] = parent.calendarItemIdentifier

        // 完了済みタスク（少しだけ）
        let done = makeReminder(
            title: "ジムに行く",
            calendar: personal,
            eventStore: eventStore,
            due: today,
            includesTime: false,
            isCompleted: true
        )
        reminders.append(done)

        return Snapshot(
            calendars: [work, personal, shopping],
            reminders: reminders,
            parentMap: parentMap
        )
    }

    // MARK: - Helpers

    @MainActor
    private static func makeCalendar(
        title: String,
        color: NSColor,
        eventStore: EKEventStore
    ) -> EKCalendar {
        let cal = EKCalendar(for: .reminder, eventStore: eventStore)
        cal.title = title
        cal.cgColor = color.cgColor
        // source は設定しない（save しないので不要）
        return cal
    }

    @MainActor
    private static func makeReminder(
        title: String,
        calendar: EKCalendar,
        eventStore: EKEventStore,
        due: Date?,
        includesTime: Bool,
        notes: String? = nil,
        isCompleted: Bool = false
    ) -> EKReminder {
        let r = EKReminder(eventStore: eventStore)
        r.title = title
        r.calendar = calendar
        r.notes = notes
        r.isCompleted = isCompleted
        if let due {
            var units: Set<Calendar.Component> = [.year, .month, .day]
            if includesTime { units.formUnion([.hour, .minute]) }
            var components = Calendar.current.dateComponents(units, from: due)
            components.calendar = Calendar(identifier: .gregorian)
            components.timeZone = .current
            if !includesTime {
                components.hour = nil
                components.minute = nil
                components.second = nil
            }
            r.dueDateComponents = components
        }
        return r
    }

    private static func setHour(_ date: Date, _ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}
