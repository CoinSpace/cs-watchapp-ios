import SwiftUI
import WidgetKit

@MainActor
@Observable
class SettingsModel {
    static let shared = SettingsModel()
    
    var cryptos: [CryptoItem] = [CryptoItem(crypto: .bitcoin)]
    var isLoading: Bool = true
    
    private let suiteName = "group.com.coinspace.shared.watchos"
    private let userDefaultsKey = "cryptos"
    
    private init() {
        loadCryptos()
    }
    
    func loadCryptos() {
        Task {
            if let defaults = UserDefaults(suiteName: suiteName),
               let data = defaults.data(forKey: userDefaultsKey),
               let decoded = try? JSONDecoder().decode([CryptoItem].self, from: data) {
                self.cryptos = decoded
            }
            self.isLoading = false
        }
    }
        
    func saveCryptos() {
        if let encoded = try? JSONEncoder().encode(cryptos),
           let defaults = UserDefaults(suiteName: suiteName) {
            defaults.set(encoded, forKey: userDefaultsKey)
            WidgetCenter.shared.invalidateConfigurationRecommendations()
            WidgetCenter.shared.reloadTimelines(ofKind: "TickerExtension")
        }
    }
    
    func addCrypto(_ item: CryptoItem) {
        guard !SettingsModel.shared.cryptos.contains(where: { $0.crypto.asset == item.crypto.asset }) else { return }
        self.cryptos.insert(item, at: 0)
        self.saveCryptos()
    }
    
    func removeCrypto(_ item: CryptoItem) {
        guard let index = SettingsModel.shared.cryptos.firstIndex(where: { $0.id == item.id }) else { return }
        self.cryptos.remove(at: index)
        self.saveCryptos()
    }
    
    func moveCrypto(from source: IndexSet, to destination: Int) {
        self.cryptos.move(fromOffsets: source, toOffset: destination)
        self.saveCryptos()
    }
    
    func updateCurrency(for item: CryptoItem, with currency: Currency) {
        guard let index = cryptos.firstIndex(where: { $0.id == item.id }) else { return }
        cryptos[index].currency = currency
        self.saveCryptos()
        Task {
            await loadPrice(for: cryptos[index])
        }
    }
    
    func loadPrice(for item: CryptoItem, forceAnimation: Bool = false) async {
        do {
            let ticker = (try await ApiClient.shared.prices([item.crypto._id], item.currency.rawValue))[0]
            guard let index = cryptos.firstIndex(where: { $0.id == item.id }) else { return }
            
            if ticker.price != cryptos[index].ticker?.price || forceAnimation {
                cryptos[index].ticker = ticker
                cryptos[index].date = Date()
            }
            WidgetCenter.shared.reloadTimelines(ofKind: "TickerExtension")
        } catch {}
    }
    
    func loadLogo(for item: CryptoItem) async {
        guard item.crypto.image == nil else { return }
        let image = await CryptoCodable.loadImage(item.crypto)
        guard let index = cryptos.firstIndex(where: { $0.id == item.id }) else { return }
        cryptos[index].crypto.image = image
    }
}
