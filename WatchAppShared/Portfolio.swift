import Foundation

struct Portfolio: Identifiable, Codable {
    var id = UUID()
    var currency: Currency = .USD
    var total: TickerCodable?
    var cryptos: [PortfolioCryptoCodable] = []
    var date = Date()
    var isLogged = false
        
    func getTotalTicker() async throws -> TickerCodable {
        let cryptoIds = cryptos.map { $0._id }
        let tickers: [TickerCodable] = try await ApiClient.shared.prices(cryptoIds, currency.rawValue)
        var balance = 0.0
        var balanceChange = 0.0
        for (index, crypto) in cryptos.enumerated() {
            let ticker = tickers[index]
            let fiat = crypto.balance * ticker.price
            balance += fiat
            balanceChange += fiat * (ticker.price_change_1d ?? 0)
        }
        let balanceChangePercent = balance == 0.0 ? 0.0 : (balanceChange / balance)
        var totalTicker = TickerCodable(cryptoId: "portfolio", price: balance, price_change_1d: balanceChangePercent)
        
        let suiteName = "group.com.coinspace.shared"
        let key = "watchapp.portfolio.ticker:\(currency.rawValue)"
        if let defaults = UserDefaults(suiteName: suiteName) {
            if let data = defaults.data(forKey: key) {
                if let decoded = try? JSONDecoder().decode(TickerCodable.self, from: data) {
                    totalTicker.delta = totalTicker.price - decoded.price
                }
            }
            if let encoded = try? JSONEncoder().encode(totalTicker) {
                defaults.set(encoded, forKey: key)
            }
        }
        return totalTicker
    }
    
    static let defaultPortfolio = Portfolio(
        cryptos: [
            PortfolioCryptoCodable(_id: "bitcoin@bitcoin", balance: 1.0),
            PortfolioCryptoCodable(_id: "litecoin@litecoin", balance: 2.0),
        ],
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
