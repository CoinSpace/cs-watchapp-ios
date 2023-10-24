//
//  ComplicationController.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 13.04.2018.
//

import ClockKit
import SwiftyJSON

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    override init() {
        super.init()
    }
    
    struct Crypto {
        let name: String
        let symbol: String
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if AppService.sharedInstance.ticker == nil {
            return handler(nil)
        }
        
        let cryptoId: String = AppService.sharedInstance.complicationCryptoId
        
        switch complication.family {
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                
                let crypto = self.getCrypto(cryptoId)
                let headerText = crypto.name
                template.headerTextProvider = CLKSimpleTextProvider(text: headerText)
                
                let priceText = AppService.sharedInstance.getPriceText(cryptoId)
                
                template.body1TextProvider = CLKSimpleTextProvider(text: priceText)
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
            
            case .graphicRectangular:
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                
                let crypto = self.getCrypto(cryptoId)
                let headerText = crypto.name
                template.headerTextProvider = CLKSimpleTextProvider(text: headerText)
                
                let priceText = AppService.sharedInstance.getPriceText(cryptoId)
                
                template.body1TextProvider = CLKSimpleTextProvider(text: priceText)
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                
                let crypto = self.getCrypto(cryptoId)
                let priceText = AppService.sharedInstance.getPriceText(cryptoId)
                let text = String(format:"\(crypto.symbol): \(priceText)")
                
                template.textProvider = CLKSimpleTextProvider(text: text)
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            default:
                handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
    func reloadComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications! {
            server.reloadTimeline(for: complication)
        }
    }
    
    func getCrypto(_ cryptoId: String) -> Crypto {
        switch cryptoId {
            case "bitcoin@bitcoin":
                return Crypto(name: "Bitcoin", symbol: "BTC")
            case "bitcoin-cash@bitcoin-cash":
                return Crypto(name: "Bitcoin Cash", symbol: "BCH")
            case "ethereum@ethereum":
                return Crypto(name: "Ethereum", symbol: "ETH")
            case "litecoin@litecoin":
                return Crypto(name: "Litecoin", symbol: "LTC")
            default:
                return Crypto(name: "", symbol: "")
        }
    }
}
