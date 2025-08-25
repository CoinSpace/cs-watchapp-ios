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
        var cryptoItem = configuration.getCryptoItem()
        do {
            cryptoItem.ticker = try await ApiClient.shared.prices([cryptoItem.crypto._id], cryptoItem.currency.rawValue).first
        } catch {}
        let now = Date()
        return TickerTimelineEntry(date: now, cryptoItem: cryptoItem)
    }

    func timeline(for configuration: TickerConfiguration, in context: Context) async -> Timeline<TickerTimelineEntry> {
        print("timeline")
        var cryptoItem = configuration.getCryptoItem()
        do {
            cryptoItem.ticker = try await ApiClient.shared.prices([cryptoItem.crypto._id], cryptoItem.currency.rawValue).first
        } catch {}
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
        default:
            Text("404")
        }
    }
}

struct TickerCornerView: View {
    let entry: TickerProvider.Entry
    
    var body: some View {
        Text(entry.cryptoItem.crypto.symbol)
            .font(.callout)
            .widgetCurvesContent()
            .widgetLabel {
                if let price = entry.cryptoItem.ticker?.price {
                    Text(AppService.shared.formatFiat(price, entry.cryptoItem.currency.rawValue, true))
                } else {
                    Text(verbatim: "...")
                }
            }
    }
}

struct TickerCircularView: View {
    var body: some View {}
}

struct TickerInlineView: View {
    var body: some View {}
}

struct TickerRectangularView: View {
    var body: some View {}
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
                    .widgetURL(URL(string: "watchapp://main"))
        }
        .configurationDisplayName("Ticker")
        .description("Live price for selected crypto.")
//        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline, .accessoryRectangular])
        .supportedFamilies([.accessoryCorner, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryCorner) {
    TickerExtension()
} timeline: {
    TickerTimelineEntry(date: .now, cryptoItem: CryptoItem(crypto: .bitcoin))
}
