import SwiftUI

@MainActor
@Observable
class SettingsModel {
    static let shared = SettingsModel()
    
    var cryptos: [CryptoItem] = []
    var isLoading: Bool = true
    
    private init() {
        loadCryptos()
    }
    
    func loadCryptos() {
        Task {
            if let data = UserDefaults.standard.data(forKey: "cryptos"),
               let decoded = try? JSONDecoder().decode([CryptoItem].self,from: data) {
                self.cryptos = decoded
            }
            self.isLoading = false
        }
    }
        
    func saveCryptos() {
        if let encoded = try? JSONEncoder().encode(cryptos) {
            UserDefaults.standard.set(encoded, forKey: "cryptos")
        }
    }
    
    func addCrypto(_ item: CryptoItem) {
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
        } catch {}
    }
    
    func loadLogo(for item: CryptoItem) async {
        guard item.crypto.image == nil else { return }
        let image = await CryptoCodable.loadImage(item.crypto)
        guard let index = cryptos.firstIndex(where: { $0.id == item.id }) else { return }
        cryptos[index].crypto.image = image
    }
}

struct CryptoItem: Identifiable, Codable {
    var id = UUID()
    var crypto: CryptoCodable
    var ticker: TickerCodable?
    var currency: Currency = .USD
    var date = Date()
}
