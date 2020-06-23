//
//  TickerService.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 27.03.2020.
//

import WatchKit
import Foundation
import SwiftyJSON

class AppService {
    static let sharedInstance = AppService()
    var ticker: JSON!
    var currencySymbol: String!
    var complicationCryptoSymbol: String!

    init() {
        currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "USD"
        complicationCryptoSymbol = UserDefaults.standard.string(forKey: "cryptoSymbol") ?? "BTC"
    }

    func setTicker(_ ticker: JSON!) {
        self.ticker = ticker
        self.refreshControllerInfo()
        self.refreshComplicationInfo()
    }

    func setCurrencySymbol(_ currencySymbol: String!) {
        UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol")
        self.currencySymbol = currencySymbol
        self.refreshComplicationInfo()
    }

    func getPriceText(_ cryptoSymbol: String) -> String {
        if ticker == nil {
            return "Loading..."
        }
        return String(format:"%.2f \(currencySymbol!)", ticker[cryptoSymbol][currencySymbol].doubleValue)
    }

    func setComplicationCryptoSymbol(_ cryptoSymbol: String) {
        UserDefaults.standard.set(cryptoSymbol, forKey: "cryptoSymbol")
        self.complicationCryptoSymbol = cryptoSymbol
        self.refreshComplicationInfo()
    }

    private func refreshControllerInfo() {
        if let cryptoController = WKExtension.shared().visibleInterfaceController as? CryptoController {
            cryptoController.updatePriceLabel()
        }
    }

    private func refreshComplicationInfo() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications! {
            server.reloadTimeline(for: complication)
        }
    }

}
