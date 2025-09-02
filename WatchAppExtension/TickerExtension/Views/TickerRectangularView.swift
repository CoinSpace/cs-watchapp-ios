import SwiftUI

struct TickerRectangularView: View {
    let entry: TickerProvider.Entry
    
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ZStack {
                    if widgetRenderingMode == .fullColor {
                        if let uiImage = entry.cryptoItem.crypto.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Circle().fill(.orange)
                        }
                    } else {
                        if let priceChange = entry.cryptoItem.ticker?.price_change_1d {
                            Image(systemName: priceChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .resizable()
                        }
                    }
                }
                .frame(width: 24.0, height: 24.0)
                Spacer()
                PriceChangeView(ticker: entry.cryptoItem.ticker)
            }
            Spacer().frame(minHeight: 0)
            VStack(alignment: .leading, spacing: -4) {
                Text(entry.cryptoItem.crypto.name)
                    .setFontStyle(AppFonts.textSm)
                PriceText
                    .setFontStyle(AppFonts.textSmBold)
            }
        }
        .padding()
    }
    
    private var PriceText: Text {
        let text: Text
        if let price = entry.cryptoItem.ticker?.price {
            text = Text(AppService.shared.formatFiat(price, entry.cryptoItem.currency.rawValue, true))
        } else {
            text = Text(verbatim: "...")
        }
        return text
    }
}
