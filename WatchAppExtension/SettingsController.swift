//
//  SettingsController.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 17.04.2018.
//

import WatchKit
import Foundation


class SettingsController: WKInterfaceController {

    @IBOutlet var currencyLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        currencyLabel.setText(AppService.sharedInstance.currencySymbol)
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
