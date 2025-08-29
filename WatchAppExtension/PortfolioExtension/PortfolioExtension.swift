import WidgetKit
import SwiftUI
import AppIntents

struct PortfolioProvider: TimelineProvider {
    
    private let suiteName = "group.com.coinspace.shared"
    private let userDefaultsKey = "watchapp.portfolio"
    
    func placeholder(in context: Context) -> PortfolioTimelineEntry {
        print("placeholder")
        let now = Date()
        return PortfolioTimelineEntry(date: now, portfolio: .defaultPortfolio)
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (PortfolioTimelineEntry) -> Void) {
        print("snapshot")
        Task {
            let now = Date()
            let portfolio = await getPortfolio()
            let entry = PortfolioTimelineEntry(date: now, portfolio: portfolio)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<PortfolioTimelineEntry>) -> Void) {
        print("timeline")
        Task {
            let now = Date()
            let portfolio = await getPortfolio()
            let entry = PortfolioTimelineEntry(date: now, portfolio: portfolio)
            let timeline = Timeline(entries: [entry], policy: .after(now.addingTimeInterval(300))) // 5 min
            completion(timeline)
        }
    }
    
    private func getPortfolio() async -> Portfolio {
        var portfolio = Portfolio()
        if let defaults = UserDefaults(suiteName: suiteName),
           let data = defaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Portfolio.self, from: data) {
            portfolio = decoded
            do {
                portfolio.total = try await portfolio.getTotalTicker()
            } catch {}
        }
        return portfolio
    }
}

struct PortfolioTimelineEntry: TimelineEntry {
    let date: Date
    let portfolio: Portfolio
}

struct PortfolioExtensionEntryView: View {
    var entry: PortfolioProvider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCorner:
            PortfolioCornerView(entry: entry)
        case .accessoryCircular:
            PortfolioCircularView(entry: entry)
        case .accessoryInline:
            PortfolioInlineView(entry: entry)
        case .accessoryRectangular:
            PortfolioRectangularView(entry: entry)
        default:
            Text(verbatim: "404")
        }
    }
}

struct PortfolioExtension: Widget {
    static let kind: String = "PortfolioExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: PortfolioExtension.kind,
            provider: PortfolioProvider()) { entry in
                PortfolioExtensionEntryView(entry: entry)
                    .containerBackground(.background.secondary, for: .widget)
                    .widgetURL(URL(string: "watchapp://portfolio"))
        }
        .configurationDisplayName("Portfolio")
        .description("The total value of your cryptos.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryRectangular) {
    PortfolioExtension()
} timeline: {
    PortfolioTimelineEntry(
        date: .now,
        portfolio: {
            var portfolio: Portfolio = .defaultPortfolio
            // DEBUG
            portfolio.isLogged = true
            portfolio.total = .bitcoin
            return portfolio
        }())
}
