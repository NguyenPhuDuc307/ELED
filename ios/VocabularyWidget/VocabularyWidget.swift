import WidgetKit
import SwiftUI

// MARK: - Shared config

private let appGroupId = "group.com.nguyenphuduc.eled"
// Must match the name passed to HomeWidget.updateWidget(name:) on the Dart side.
private let widgetKind = "VocabularyWidgetProvider"

// MARK: - Color helpers (light / dark to mirror the Android widget palette)

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

private extension Color {
    static func dyn(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { trait in
            UIColor(rgb: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private enum Palette {
    static let bg          = Color.dyn(0xFAF5F2, 0x1E293B)
    static let stroke      = Color.dyn(0xEDE0D8, 0x334155)
    static let textPrimary = Color.dyn(0x1A1A1A, 0xF1F5F9)
    static let textMuted   = Color.dyn(0xA89890, 0x94A3B8)
    static let textBrand   = Color.dyn(0x3A6B36, 0x6DBF67)
    static let levelBg     = Color.dyn(0xC8DEC4, 0x2D4A2A)
    static let levelText   = Color.dyn(0x2A4A28, 0xA8D4A4)
    static let topicBg     = Color.dyn(0xF5E4CC, 0x3D2A14)
    static let topicText   = Color.dyn(0x5A3A18, 0xD4A87A)
}

// MARK: - Timeline

struct VocabEntry: TimelineEntry {
    let date: Date
    let word: String
    let translation: String
    let ipa: String
    let pos: String
    let levels: String
    let topic: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> VocabEntry {
        VocabEntry(
            date: Date(),
            word: "serendipity",
            translation: "sự tình cờ may mắn",
            ipa: "/ˌserənˈdɪpəti/",
            pos: "noun",
            levels: "C1",
            topic: "Feelings"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (VocabEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VocabEntry>) -> Void) {
        let entry = readEntry()
        // Fallback refresh; the app also pushes updates via reloadTimelines on save.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
            ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func readEntry() -> VocabEntry {
        let d = UserDefaults(suiteName: appGroupId)
        func val(_ key: String) -> String { d?.string(forKey: key) ?? "" }
        let word = val("word")
        return VocabEntry(
            date: Date(),
            word: word.isEmpty ? "ELED" : word,
            translation: {
                let t = val("translation")
                return t.isEmpty ? "Mở app để học từ mới" : t
            }(),
            ipa: val("ipa"),
            pos: val("pos"),
            levels: val("levels"),
            topic: val("topic")
        )
    }
}

// MARK: - View

struct VocabularyWidgetEntryView: View {
    var entry: Provider.Entry

    private var posIpa: String {
        [entry.pos, entry.ipa].filter { !$0.isEmpty }.joined(separator: "  ")
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Decorative monstera, top-right
            Image("home_plant")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(0.45)
                .offset(x: 14, y: -16)

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Text("ELED")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.1)
                        .foregroundColor(Palette.textBrand)
                    Spacer(minLength: 4)
                    if !entry.levels.isEmpty {
                        Text(entry.levels)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Palette.levelText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Palette.levelBg))
                    }
                }

                Spacer(minLength: 6)

                // Word
                Text(entry.word)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !posIpa.isEmpty {
                    Text(posIpa)
                        .font(.system(size: 11, weight: .regular).italic())
                        .foregroundColor(Palette.textMuted)
                        .lineLimit(1)
                        .padding(.top, 2)
                }

                // Divider
                Rectangle()
                    .fill(Palette.textMuted.opacity(0.5))
                    .frame(width: 32, height: 1)
                    .padding(.vertical, 10)

                // Translation
                Text(entry.translation)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Palette.textPrimary)
                    .lineLimit(2)

                Spacer(minLength: 6)

                // Footer topic badge
                if !entry.topic.isEmpty {
                    Text(entry.topic)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Palette.topicText)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.topicBg))
                }
            }
        }
        .padding(14)
        .widgetURL(URL(string: "eled://widget"))
        .widgetBackground(Palette.bg)
    }
}

private extension View {
    @ViewBuilder
    func widgetBackground(_ bg: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(bg, for: .widget)
        } else {
            background(bg)
        }
    }
}

// MARK: - Widget

@main
struct VocabularyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: widgetKind, provider: Provider()) { entry in
            VocabularyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ELED Từ vựng")
        .description("Học một từ mới mỗi khi nhìn vào màn hình chính.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
