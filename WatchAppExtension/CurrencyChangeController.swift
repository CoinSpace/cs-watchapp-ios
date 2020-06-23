//
//  CurrencyChangeController.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 17.04.2018.
//

import WatchKit
import Foundation

class CurrencyChangeController: WKInterfaceController {

    @IBOutlet var currencyPicker: WKInterfacePicker!
    @IBOutlet var confirmButton: WKInterfaceButton!
    
    var selectedIndex: Int!
    
    var currencyList = ["AUD", "BRL", "CAD", "CHF", "CNY",
                        "DKK", "EUR", "GBP", "IDR", "ILS",
                        "JPY", "MXN", "NOK", "NZD", "PLN",
                        "RUB", "SEK", "SGD", "TRY", "UAH",
                        "USD", "ZAR"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let pickerItems: [WKPickerItem] = currencyList.map {
            let pickerItem = WKPickerItem()
            pickerItem.caption = $0
            pickerItem.title = $0
            return pickerItem
        }
        self.currencyPicker.setItems(pickerItems)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        super.didAppear()
        
        let currencySymbol: String = AppService.sharedInstance.currencySymbol
        self.selectedIndex = currencyList.index(of: currencySymbol)!
        self.currencyPicker.setSelectedItemIndex(self.selectedIndex)
        self.currencyPicker.focus()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func confirm() {
        let currencySymbol = currencyList[self.selectedIndex]
        AppService.sharedInstance.setCurrencySymbol(currencySymbol)
        self.dismiss()
    }
    
    @IBAction func pickerChanged(_ value: Int) {
        self.selectedIndex = value
    }

}
