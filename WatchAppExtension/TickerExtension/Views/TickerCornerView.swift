import SwiftUI

struct TickerCornerView: View {
    let entry: TickerProvider.Entry
    
    var body: some View {
        Text(entry.cryptoItem.crypto.symbol)
            .widgetCurvesContent()
            .widgetLabel {
                if let price = entry.cryptoItem.ticker?.price {
                    Text(AppService.shared.formatFiat(price, entry.cryptoItem.currency.rawValue, true))
                        .setPriceChangeColor(entry.cryptoItem)
                } else {
                    Text(verbatim: "...")
                }
            }
    }
}
