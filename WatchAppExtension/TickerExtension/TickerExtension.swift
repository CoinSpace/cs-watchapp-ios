import WidgetKit
import SwiftUI
import AppIntents

struct TickerProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TickerTimelineEntry {
        print("placeholder")
        let now = Date()
//        return TickerTimelineEntry(date: now, configuration: TickerConfiguration.defaultConfiguration, ticker: TickerCodable.bitcoin)
        return TickerTimelineEntry(date: now, configuration: TickerConfiguration.defaultConfiguration)
    }

    func snapshot(for configuration: TickerConfiguration, in context: Context) async -> TickerTimelineEntry {
        print("snapshot")
//        var ticker: TickerCodable?
//        do {
//            ticker = try await ApiClient.shared.prices([configuration.crypto.cryptoId], configuration.currency.rawValue).first
//        } catch {}
        let now = Date()
//        return TickerTimelineEntry(date: now, configuration: configuration, ticker: ticker)
        return TickerTimelineEntry(date: now, configuration: configuration)
    }

    func timeline(for configuration: TickerConfiguration, in context: Context) async -> Timeline<TickerTimelineEntry> {
//        print("timeline")
//        var ticker: TickerCodable?
//        do {
//            ticker = try await ApiClient.shared.prices([configuration.crypto.cryptoId], configuration.currency.rawValue).first
//        } catch {}
//
        let now = Date()
//        let entry = TickerTimelineEntry(date: now, configuration: configuration, ticker: ticker)
        let entry = TickerTimelineEntry(date: now, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .after(now.addingTimeInterval(300))) // 5 min
        return timeline
    }

//    func recommendations() -> [AppIntentRecommendation<TickerConfiguration>] {
//        return []
//    }
    
    func recommendations() -> [AppIntentRecommendation<TickerConfiguration>] {
        var recs = [AppIntentRecommendation<TickerConfiguration>]()

//          for backyard in Backyard.allBackyards(modelContext: modelContext) {
            let configIntent = TickerConfiguration()
//        configIntent.emoji = "11"
        
            let configIntent2 = TickerConfiguration()
//        configIntent.emoji = "22"
//            configIntent.backyardID = backyard.id.uuidString
        let gardenRecommendation = AppIntentRecommendation(intent: configIntent, description: "11")
        let gardenRecommendation2 = AppIntentRecommendation(intent: configIntent2, description: "22")
        recs.append(gardenRecommendation)
        recs.append(gardenRecommendation2)
//          }

      return recs
    }

}

struct TickerTimelineEntry: TimelineEntry {
    let date: Date
    let configuration: TickerConfiguration
//    let ticker: TickerCodable?
}

struct TickerExtensionEntryView: View {
    var entry: TickerProvider.Entry

//    @Environment(\.widgetFamily) var family
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.widgetContentMargins) var widgetContentMargins

    var body: some View {
        VStack {
            HStack {
                Text("Time111:")
                Text(entry.date, style: .time)
            }
            Text("Emoji:")
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
                .containerBackground(for: .widget) { Color.red }
//                    .containerBackground(Color(.red), for: .widget)
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
    TickerTimelineEntry(date: .now, configuration: TickerConfiguration.defaultConfiguration)
}
