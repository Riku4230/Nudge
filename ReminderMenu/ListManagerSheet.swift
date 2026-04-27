import SwiftUI

struct ListManagerSheet: View {
    @EnvironmentObject private var store: ReminderStore
    @EnvironmentObject private var app: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var editingID: String?
    @State private var draftName: String = ""
    @State private var draftColor: Color = MRTheme.accent
    @State private var deleteConfirm: ReminderCalendar?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("リストを管理")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.secondaryText)
                        .frame(width: 22, height: 22)
                        .background(Color.black.opacity(0.05), in: Circle())
                }
                .buttonStyle(.plain)
                .help("閉じる")
            }

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(store.calendars) { calendar in
                        if editingID == calendar.id {
                            editingRow(for: calendar)
                        } else {
                            row(for: calendar)
                        }
                    }
                }
            }
            .frame(maxHeight: 380)

            Divider().opacity(0.4)

            HStack {
                Spacer()
                Button("完了") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(MRTheme.accent)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(18)
        .alert(item: $deleteConfirm) { cal in
            Alert(
                title: Text("「\(cal.title)」を削除"),
                message: Text("このリスト内のすべてのリマインダーも削除されます。"),
                primaryButton: .destructive(Text("削除")) {
                    delete(cal)
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }

    private func row(for calendar: ReminderCalendar) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(calendar.color)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 1) {
                Text(calendar.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
                Text("\(calendar.count) 件 · \(calendar.sourceTitle)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondaryText)
            }
            Spacer()
            Button {
                draftName = calendar.title
                draftColor = matchingColor(for: calendar.color)
                editingID = calendar.id
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondaryText)
                    .frame(width: 26, height: 24)
                    .background(Color.black.opacity(0.04), in: Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .help("編集")

            Button(role: .destructive) {
                deleteConfirm = calendar
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MRTheme.red)
                    .frame(width: 26, height: 24)
                    .background(Color.black.opacity(0.04), in: Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .help("削除")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }

    private func editingRow(for calendar: ReminderCalendar) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(draftColor)
                    .frame(width: 14, height: 14)
                TextField("リスト名", text: $draftName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .onSubmit { save(calendar) }
            }

            HStack(spacing: 8) {
                ForEach(Array(MRTheme.listColors.enumerated()), id: \.offset) { _, color in
                    Button {
                        draftColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(sameColor(color, draftColor) ? 0.7 : 0), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 6) {
                Spacer()
                Button("キャンセル") {
                    editingID = nil
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.secondaryText)
                .font(.system(size: 12))

                Button("保存") {
                    save(calendar)
                }
                .buttonStyle(.borderedProminent)
                .tint(MRTheme.accent)
                .controlSize(.small)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(MRTheme.accent.opacity(0.4), lineWidth: 1)
        )
    }

    private func save(_ calendar: ReminderCalendar) {
        do {
            try store.updateList(id: calendar.id, name: draftName, color: draftColor)
            editingID = nil
            app.showToast(ToastMessage(kind: .success, title: "リストを更新しました", detail: draftName))
        } catch {
            app.showToast(ToastMessage(kind: .failure, title: "更新できませんでした", detail: error.localizedDescription))
        }
    }

    private func delete(_ calendar: ReminderCalendar) {
        do {
            try store.deleteList(id: calendar.id)
            app.showToast(ToastMessage(kind: .success, title: "リストを削除しました", detail: calendar.title))
        } catch {
            app.showToast(ToastMessage(kind: .failure, title: "削除できませんでした", detail: error.localizedDescription))
        }
    }

    private func matchingColor(for current: Color) -> Color {
        if let match = MRTheme.listColors.first(where: { sameColor($0, current) }) {
            return match
        }
        return MRTheme.accent
    }

    private func sameColor(_ a: Color, _ b: Color) -> Bool {
        let aNS = MRTheme.nsColor(for: a)
        let bNS = MRTheme.nsColor(for: b)
        return aNS == bNS
    }
}

