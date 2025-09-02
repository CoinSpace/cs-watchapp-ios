import WidgetKit
import AppIntents

public struct TickerConfiguration: WidgetConfigurationIntent {
    
    private static let suiteName = "group.com.coinspace.shared.watchos"
    private static let userDefaultsKey = "cryptos"
    
    public static var title: LocalizedStringResource { "Ticker configuration" }
    
    @Parameter(title: "Crypto", default: "")
    var cryptoItemId: String
    
    init(cryptoItemId: String) {
        self.cryptoItemId = cryptoItemId
    }
    public init() {}
    
    func getCryptoItem(_ context: TimelineProviderContext) async -> CryptoItem {
        var cryptoItem = CryptoItem(crypto: .bitcoin)
        if let defaults = UserDefaults(suiteName: Self.suiteName),
           let data = defaults.data(forKey: Self.userDefaultsKey),
           let decoded = try? JSONDecoder().decode([CryptoItem].self, from: data) {
            if let crypto = decoded.first(where: { $0.id.uuidString == self.cryptoItemId }) {
                cryptoItem = crypto
            }
        }
        do {
            cryptoItem.ticker = try await ApiClient.shared.prices([cryptoItem.crypto._id], cryptoItem.currency.rawValue).first
        } catch {}
        if context.family == .accessoryRectangular {
            cryptoItem.crypto.image = await CryptoCodable.loadImage(cryptoItem.crypto)
        }
        return cryptoItem
    }
    
    static func getRecommendations() -> [AppIntentRecommendation<Self>] {
        var recommendations = [AppIntentRecommendation<Self>]()
        if let defaults = UserDefaults(suiteName: Self.suiteName),
           let data = defaults.data(forKey: Self.userDefaultsKey),
           let decoded = try? JSONDecoder().decode([CryptoItem].self, from: data) {
            for cryptoItem in decoded {
                let recommendation = AppIntentRecommendation(intent: self.init(cryptoItemId: cryptoItem.id.uuidString), description: cryptoItem.crypto.name)
                recommendations.append(recommendation)
            }
        }
        return recommendations
    }
}
