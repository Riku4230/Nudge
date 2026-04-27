import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "システム"
        case .light: return "ライト"
        case .dark: return "ダーク"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct ToastMessage: Identifiable, Equatable {
    enum Kind {
        case success
        case failure
        case info
    }

    let id = UUID()
    let kind: Kind
    let title: String
    let detail: String?
}

final class AppCoordinator: ObservableObject {
    @Published var appearance: AppearanceMode {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceKey) }
    }

    @Published var toast: ToastMessage?
    @Published var quickAddToken = UUID()
    @Published var quickAddShouldOpenOptions = false
    @Published var requestedPopoverHeight: CGFloat = 540

    var showPopover: (() -> Void)?

    private var toastTask: Task<Void, Never>?
    private static let appearanceKey = "appearanceMode"

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.appearanceKey) ?? AppearanceMode.system.rawValue
        appearance = AppearanceMode(rawValue: raw) ?? .system
    }

    func showQuickAdd(openOptions: Bool = true) {
        quickAddShouldOpenOptions = openOptions
        showPopover?()
        quickAddToken = UUID()
    }

    func showToast(_ message: ToastMessage, duration: UInt64 = 3_200_000_000) {
        toastTask?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            toast = message
        }
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: duration)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.18)) {
                toast = nil
            }
        }
    }

    func showAddedToast(titles: [String]) {
        let visible = titles.prefix(4).joined(separator: "、")
        let suffix = titles.count > 4 ? " ほか\(titles.count - 4)件" : ""
        showToast(
            ToastMessage(
                kind: .success,
                title: "\(titles.count)件のタスクを追加しました",
                detail: visible + suffix
            )
        )
    }
}
