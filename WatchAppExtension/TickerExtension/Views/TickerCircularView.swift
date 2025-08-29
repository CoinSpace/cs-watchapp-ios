import SwiftUI
import WidgetKit

struct TickerCircularView: View {
    let entry: TickerProvider.Entry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -6) {
                Text(entry.cryptoItem.crypto.symbol)
                    .setFontStyle(AppFonts.textXsBold)
                    .minimumScaleFactor(0.9)
                PriceText
                    .setFontStyle(AppFonts.textXsBold)
                    .minimumScaleFactor(0.7)
            }.padding(.horizontal, 2)
        }
    }
    
    private var PriceText: Text {
        let text: Text
        if let priceChange = entry.cryptoItem.ticker?.price_change_1d {
            text = Text(String(format: "%+.1f%%", priceChange))
        } else {
            text = Text(verbatim: "...")
        }
        return text.setPriceChangeColor(entry.cryptoItem.ticker?.price_change_1d)
    }
}
