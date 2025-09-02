import SwiftUI

struct PortfolioInlineView: View {
    let entry: PortfolioProvider.Entry
    
    var body: some View {
        Image("CoinWallet")
        if entry.portfolio.isLogged {
            if let price = entry.portfolio.total?.price {
                Text(AppService.shared.formatFiat(price, entry.portfolio.currency.rawValue, false))
            } else {
                Text(verbatim: "...")
            }
        } else {
            Text("Sign In")
        }
        
    }
}
