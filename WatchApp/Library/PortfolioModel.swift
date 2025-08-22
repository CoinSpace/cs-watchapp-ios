import SwiftUI

@MainActor
@Observable
class PortfolioModel {
    static let shared = PortfolioModel()
    
    var portfolio: Portfolio = Portfolio()
    var isLoading: Bool = true
    
    private init() {
        loadPortfolio()
    }
    
    func loadPortfolio() {
        Task {
            if let data = UserDefaults.standard.data(forKey: "portfolio"),
               let decoded = try? JSONDecoder().decode(Portfolio.self, from: data) {
                self.portfolio = decoded
            }
//            DEBUG
//            self.portfolio = Portfolio.defaultPortfolio
            self.isLoading = false
        }
    }
    
    func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(self.portfolio) {
            UserDefaults.standard.set(encoded, forKey: "portfolio")
        }
    }
    
    func loadPrice(forceAnimation: Bool = false) async {
        var tickers: [TickerCodable] = []
        do {
            let cryptoIds = self.portfolio.cryptos.map { $0._id }
            tickers = try await ApiClient.shared.prices(cryptoIds, self.portfolio.currency.rawValue)
            let totalTicker = self.getTotalTicker(tickers)
            if totalTicker.price != self.portfolio.total?.price || forceAnimation {
                self.portfolio.total = totalTicker
                self.portfolio.date = Date()
            }
        } catch {}
    }
    
    func updateCurrency(with currency: Currency) {
        self.portfolio.currency = currency
        self.savePortfolio()
        Task {
            await loadPrice()
        }
    }
    
    func updatePortfolio(data: String) {
        if let jsonData = data.data(using: .utf8) {
            if let decoded = try? JSONDecoder().decode([PortfolioCryptoCodable].self, from: jsonData) {
                self.portfolio.cryptos = decoded
                self.portfolio.isLogged = true
            } else {
                self.portfolio.cryptos = []
                self.portfolio.isLogged = false
            }
        }
        self.savePortfolio()
        Task {
            await loadPrice()
        }
    }
    
    private func getTotalTicker(_ tickers: [TickerCodable]) -> TickerCodable {
        var balance = 0.0
        var balanceChange = 0.0
        for (index, crypto) in self.portfolio.cryptos.enumerated() {
            let ticker = tickers[index]
            let fiat = crypto.balance * ticker.price
            balance += fiat
            balanceChange += fiat * (ticker.price_change_1d ?? 0)
        }
        let balanceChangePercent = balance == 0.0 ? 0.0 : (balanceChange / balance)
        var totalTicker = TickerCodable(cryptoId: "portfolio", price: balance, price_change_1d: balanceChangePercent)
        
        let key = "portfolio:\(self.portfolio.currency.rawValue)"
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode(TickerCodable.self, from: data) {
                totalTicker.delta = totalTicker.price - decoded.price
            }
        }
        if let encoded = try? JSONEncoder().encode(totalTicker) {
            defaults.set(encoded, forKey: key)
        }
        return totalTicker
    }
}

struct Portfolio: Identifiable, Codable {
    var id = UUID()
    var currency: Currency = .USD
    var total: TickerCodable?
    var cryptos: [PortfolioCryptoCodable] = []
    var date = Date()
    var isLogged = false
    
    static let defaultPortfolio = Portfolio(
        cryptos: [
            PortfolioCryptoCodable(_id: "bitcoin@bitcoin", balance: 1.0),
            PortfolioCryptoCodable(_id: "litecoin@litecoin", balance: 2.0),
        ]
    )
}

struct PortfolioCryptoCodable: Codable {
    let _id: String
    let balance: Double

    init(_id: String, balance: Double) {
        self._id = _id
        self.balance = balance
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decode(String.self, forKey: ._id)
        let balanceString = try values.decode(String.self, forKey: .balance)
        if let value = Double(balanceString) {
            balance = value
        } else {
            balance = 0
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(String(balance), forKey: .balance)
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id, balance
    }
}
