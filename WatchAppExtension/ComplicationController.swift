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
        
        let cryptoSymbol: String = AppService.sharedInstance.complicationCryptoSymbol
        
        switch complication.family {
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                
                let headerText = self.getCryptoName(cryptoSymbol)
                template.headerTextProvider = CLKSimpleTextProvider(text: headerText)
                
                let priceText = AppService.sharedInstance.getPriceText(cryptoSymbol)
                
                template.body1TextProvider = CLKSimpleTextProvider(text: priceText)
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))            
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                
                let priceText = AppService.sharedInstance.getPriceText(cryptoSymbol)
                let text = String(format:"\(cryptoSymbol): \(priceText)")
                
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
    
    func getCryptoName(_ symbol: String) -> String {
        switch symbol {
            case "BTC":
                return "Bitcoin"
            case "BCH":
                return "Bitcoin Cash"
            case "ETH":
                return "Ethereum"
            case "LTC":
                return "Litecoin"
            default:
                return ""
        }
    }
    
}
