import SwiftUI
import WidgetKit

@MainActor
@Observable
class PortfolioModel {
    static let shared = PortfolioModel()
    
    var portfolio: Portfolio = Portfolio()
    var isLoading: Bool = true
    
    private let suiteName = "group.com.coinspace.shared"
    private let userDefaultsKey = "watchapp.portfolio"
    
    private init() {
        loadPortfolio()
    }
    
    func loadPortfolio() {
        Task {
            if let defaults = UserDefaults(suiteName: suiteName),
               let data = defaults.data(forKey: userDefaultsKey),
               let decoded = try? JSONDecoder().decode(Portfolio.self, from: data) {
                self.portfolio = decoded
            } else {
                savePortfolio()
            }
            // DEBUG
            // self.portfolio = Portfolio.defaultPortfolio
            self.isLoading = false
        }
    }
    
    func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(self.portfolio),
           let defaults = UserDefaults(suiteName: suiteName) {
            defaults.set(encoded, forKey: userDefaultsKey)
            WidgetCenter.shared.reloadTimelines(ofKind: "PortfolioExtension")
        }
    }
    
    func loadPrice(forceAnimation: Bool = false) async {
        do {
            let totalTicker = try await self.portfolio.getTotalTicker()
            if totalTicker.price != self.portfolio.total?.price || forceAnimation {
                self.portfolio.total = totalTicker
                self.portfolio.date = Date()
            }
            WidgetCenter.shared.reloadTimelines(ofKind: "PortfolioExtension")
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
}
