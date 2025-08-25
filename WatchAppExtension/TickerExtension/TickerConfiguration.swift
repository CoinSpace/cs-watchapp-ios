import WidgetKit
import AppIntents

public struct TickerConfiguration: WidgetConfigurationIntent {
    
    private static let suiteName = "group.com.coinspace.shared"
    private static let userDefaultsKey = "watchapp.cryptos"
    
    public static var title: LocalizedStringResource { "Ticker configuration" }
    
    @Parameter(title: "Crypto", default: "")
    var cryptoItemId: String
    
    init(cryptoItemId: String) {
        self.cryptoItemId = cryptoItemId
    }
    public init() {}
    
    func getCryptoItem() -> CryptoItem {
        var cryptoItem = CryptoItem(crypto: .bitcoin)
        if let defaults = UserDefaults(suiteName: Self.suiteName),
           let data = defaults.data(forKey: Self.userDefaultsKey),
           let decoded = try? JSONDecoder().decode([CryptoItem].self, from: data) {
            if let crypto = decoded.first(where: { $0.id.uuidString == self.cryptoItemId }) {
                cryptoItem = crypto
            }
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
