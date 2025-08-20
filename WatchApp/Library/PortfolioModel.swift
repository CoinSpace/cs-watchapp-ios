import SwiftUI

import WatchConnectivity

@MainActor
@Observable
class PortfolioModel {
    static let shared = PortfolioModel()
    
    private let delegate: WCSessionDelegate
    private var session: WCSession
    
    var portfolio: Portfolio?
    var isLoading: Bool = true
    
    private init(session: WCSession = .default) {
        self.delegate = SessionDelegater()
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        loadPortfolio()
    }
    
    func loadPortfolio() {
        Task {
            if let data = UserDefaults.standard.data(forKey: "portfolio"),
               let decoded = try? JSONDecoder().decode(Portfolio.self,from: data) {
                self.portfolio = decoded
            }
//            DEBUG
//            self.portfolio = Portfolio.defaultPortfolio
            self.isLoading = false
        }
    }
    
    func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(encoded, forKey: "portfolio")
        }
    }
    
    func loadPrice(for portfolio: Portfolio, forceAnimation: Bool = false) async {
        var tickers: [TickerCodable] = []
        do {
            let cryptoIds = portfolio.cryptos.map { $0._id }
            tickers = try await ApiClient.shared.prices(cryptoIds, portfolio.currency.rawValue)
            let totalTicker = self.getTotalTicker(portfolio, tickers)
            if totalTicker.price != self.portfolio?.total?.price || forceAnimation {
                self.portfolio?.total = totalTicker
                self.portfolio?.date = Date()
            }
        } catch {}
    }
    
    func updateCurrency(for portfolio: Portfolio, with currency: Currency) {
        self.portfolio?.currency = currency
        self.savePortfolio()
        Task {
            await loadPrice(for: self.portfolio!)
        }
    }
    
    private func getTotalTicker(_ portfolio: Portfolio, _ tickers: [TickerCodable]) -> TickerCodable {
        var balance = 0.0
        var balanceChange = 0.0
        for (index, crypto) in portfolio.cryptos.enumerated() {
            let ticker = tickers[index]
            let fiat = crypto.balance * ticker.price
            balance += fiat
            balanceChange += fiat * (ticker.price_change_1d ?? 0)
        }
        let balanceChangePercent = balance == 0.0 ? 0.0 : (balanceChange / balance)
        var totalTicker = TickerCodable(cryptoId: "portfolio", price: balance, price_change_1d: balanceChangePercent)
        
        let key = "portfolio:\(portfolio.currency.rawValue)"
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

class SessionDelegater: NSObject, WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
        // nothing to update in the model here
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let portfolioCryptos = message["portfolioCryptos"] as? String {
            Task { @MainActor in
                print(portfolioCryptos)
//                PortfolioModel.shared.portfolio = balance
            }
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let portfolioCryptos = userInfo["portfolioCryptos"] as? String {
            Task { @MainActor in
                print(portfolioCryptos)
//                self.model.balance = balance
            }
        }
    }
}

struct Portfolio: Identifiable, Codable {
    var id = UUID()
    var currency: Currency = .USD
    var total: TickerCodable?
    let cryptos: [PortfolioCryptoCodable]
    var date = Date()
    
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
}
