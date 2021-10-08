//
//  EthereumController.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 20.04.2018.
//

import WatchKit
import Foundation
import SwiftyJSON

class EthereumController: CryptoController {

    @IBOutlet var priceLabel: WKInterfaceLabel!
    let cryptoId = "ethereum@ethereum"
        
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
            
    override func updatePriceLabel() {
        self.priceLabel.setText(AppService.sharedInstance.getPriceText(cryptoId))
    }
    
    @IBAction func buttonClick() {
        let message = "Display Ethereum price on the watch face?"
        let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default, handler: { () -> Void in
            AppService.sharedInstance.setComplicationCryptoId(self.cryptoId)
        })
        self.presentAlert(withTitle: "", message: message, preferredStyle: WKAlertControllerStyle.actionSheet, actions: [action])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.updatePriceLabel()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
