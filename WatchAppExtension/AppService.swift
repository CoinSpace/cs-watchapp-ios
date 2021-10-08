//
//  TickerService.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 27.03.2020.
//

import WatchKit
import Foundation
import SwiftyJSON
import ClockKit

class AppService {
    static let sharedInstance = AppService()
    var ticker: JSON!
    var currencySymbol: String!
    var complicationCryptoId: String!

    init() {
        currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "USD"
        complicationCryptoId = UserDefaults.standard.string(forKey: "cryptoId") ?? "bitcoin@bitcoin"
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

    func getPriceText(_ cryptoId: String) -> String {
        if ticker == nil {
            return "Loading..."
        }
        var cryptoTicker: JSON!
        for (_, subJson):(String, JSON) in ticker {
            if (subJson["_id"].string == cryptoId) {
                cryptoTicker = subJson
                break
            }
        }
        return String(format:"%.2f \(currencySymbol!)", cryptoTicker["prices"][currencySymbol].doubleValue)
    }

    func setComplicationCryptoId(_ cryptoId: String) {
        UserDefaults.standard.set(cryptoId, forKey: "cryptoId")
        self.complicationCryptoId = cryptoId
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
