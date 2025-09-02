import SwiftUI

struct PortfolioCornerView: View {
    let entry: PortfolioProvider.Entry
    
    var body: some View {
        Image("CoinWallet")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .widgetLabel {
                if entry.portfolio.isLogged {
                    if let price = entry.portfolio.total?.price {
                        Text(AppService.shared.formatFiat(price, entry.portfolio.currency.rawValue, false))
                            .setPriceChangeColor(entry.portfolio.total?.price_change_1d)
                    } else {
                        Text(verbatim: "...")
                    }
                } else {
                    Text("Sign In")
                }
            }
    }
}
