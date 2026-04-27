import AppKit
import SwiftUI

enum MRTheme {
    static let accent = Color(red: 0.22, green: 0.52, blue: 0.95)
    static let accentSoft = Color(red: 0.22, green: 0.52, blue: 0.95).opacity(0.16)
    static let accentFaint = Color(red: 0.22, green: 0.52, blue: 0.95).opacity(0.08)
    static let blue = Color(red: 0.18, green: 0.56, blue: 0.95)
    static let purple = Color(red: 0.62, green: 0.38, blue: 0.95)
    static let pink = Color(red: 0.95, green: 0.36, blue: 0.58)
    static let green = Color(red: 0.28, green: 0.74, blue: 0.48)
    static let yellow = Color(red: 0.88, green: 0.72, blue: 0.24)
    static let red = Color(red: 0.95, green: 0.22, blue: 0.24)
    static let gray = Color(red: 0.52, green: 0.52, blue: 0.48)

    static let listColors: [Color] = [accent, blue, green, purple, pink, red, yellow, gray]

    static func nsColor(for color: Color) -> NSColor {
        switch color {
        case blue: return NSColor.systemBlue
        case green: return NSColor.systemGreen
        case purple: return NSColor.systemPurple
        case pink: return NSColor.systemPink
        case red: return NSColor.systemRed
        case yellow: return NSColor.systemYellow
        case gray: return NSColor.systemGray
        default: return NSColor.systemOrange
        }
    }
}

extension Color {
    static var primaryText: Color { Color(nsColor: .labelColor) }
    static var secondaryText: Color { Color(nsColor: .secondaryLabelColor) }
    static var tertiaryText: Color { Color(nsColor: .tertiaryLabelColor) }
}

extension DateFormatter {
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter
    }()

    static let dayAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E H:mm"
        return formatter
    }()

    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "H:mm"
        return formatter
    }()
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 34, height: 34)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
