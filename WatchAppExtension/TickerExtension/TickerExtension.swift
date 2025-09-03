import WidgetKit
import SwiftUI
import AppIntents

struct TickerProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TickerTimelineEntry {
        print("placeholder")
        let now = Date()
        return TickerTimelineEntry(date: now, cryptoItem: CryptoItem(crypto: .bitcoin))
    }

    func snapshot(for configuration: TickerConfiguration, in context: Context) async -> TickerTimelineEntry {
        print("snapshot")
        let cryptoItem = await configuration.getCryptoItem(context)
        let now = Date()
        return TickerTimelineEntry(date: now, cryptoItem: cryptoItem)
    }

    func timeline(for configuration: TickerConfiguration, in context: Context) async -> Timeline<TickerTimelineEntry> {
        print("timeline")
        let cryptoItem = await configuration.getCryptoItem(context)
        let now = Date()
        let entry = TickerTimelineEntry(date: now, cryptoItem: cryptoItem)
        let timeline = Timeline(entries: [entry], policy: .after(now.addingTimeInterval(300))) // 5 min
        return timeline
    }

    func recommendations() -> [AppIntentRecommendation<TickerConfiguration>] {
        return TickerConfiguration.getRecommendations()
    }
}

struct TickerTimelineEntry: TimelineEntry {
    let date: Date
    let cryptoItem: CryptoItem
}

struct TickerExtensionEntryView: View {
    var entry: TickerProvider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCorner:
            TickerCornerView(entry: entry)
        case .accessoryCircular:
            TickerCircularView(entry: entry)
        case .accessoryInline:
            TickerInlineView(entry: entry)
        case .accessoryRectangular:
            TickerRectangularView(entry: entry)
        default:
            Text(verbatim: "404")
        }
    }
}

struct TickerExtension: Widget {
    static let kind: String = "TickerExtension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: TickerExtension.kind,
            intent: TickerConfiguration.self,
            provider: TickerProvider()) { entry in
            TickerExtensionEntryView(entry: entry)
                    .containerBackground(.background.secondary, for: .widget)
                    .widgetURL(URL(string: "watchapp://main?cryptoItemId=\(entry.cryptoItem.id)"))
        }
        .configurationDisplayName("Ticker")
        .description("Live price for selected crypto.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryRectangular) {
    TickerExtension()
} timeline: {
    TickerTimelineEntry(date: .now, cryptoItem: CryptoItem(crypto: .bitcoin, ticker: .bitcoin))
}
