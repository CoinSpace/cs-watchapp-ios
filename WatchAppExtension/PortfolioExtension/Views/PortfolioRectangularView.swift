import SwiftUI

struct PortfolioRectangularView: View {
    let entry: PortfolioProvider.Entry
    
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ZStack {
                    if widgetRenderingMode == .fullColor {
                        Image("CoinWallet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        if let priceChange = entry.portfolio.total?.price_change_1d {
                            Image(systemName: priceChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .resizable()
                        }
                    }
                }
                .frame(width: 24.0, height: 24.0)
                Spacer()
                PriceChangeView(ticker: entry.portfolio.total)
            }
            Spacer().frame(minHeight: 0)
            VStack(alignment: .leading, spacing: -4) {
                Text("Portfolio")
                    .setFontStyle(AppFonts.textSm)
                if entry.portfolio.isLogged {
                    PriceText
                        .setFontStyle(AppFonts.textSmBold)
                } else {
                    Text("Sign In")
                        .setFontStyle(AppFonts.textSmBold)
                }
            }
        }
        .padding()
    }
    
    private var PriceText: Text {
        let text: Text
        if let price = entry.portfolio.total?.price {
            text = Text(AppService.shared.formatFiat(price, entry.portfolio.currency.rawValue, false))
        } else {
            text = Text(verbatim: "...")
        }
        return text
    }
}
