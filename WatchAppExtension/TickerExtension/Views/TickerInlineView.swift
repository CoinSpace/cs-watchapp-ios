import SwiftUI

struct TickerInlineView: View {
    let entry: TickerProvider.Entry
    
    var body: some View {
        if let price = entry.cryptoItem.ticker?.price {
            Text(verbatim: "\(entry.cryptoItem.crypto.symbol) \(AppService.shared.formatFiat(price, entry.cryptoItem.currency.rawValue, true))")
        } else {
            Text(verbatim: "...")
        }
    }
}
