import SwiftUICore
import SwiftUI

struct FontStyle {
    let size: CGFloat
    let weight: Font.Weight
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
}

struct AppFonts {
    static let textXs = FontStyle(size: 12, weight: .regular, lineHeight: 1.5, letterSpacing: 0.03)
    static let textXsBold = FontStyle(size: 12, weight: .semibold, lineHeight: 1.5, letterSpacing: 0.03)
    
    static let textSm = FontStyle(size: 14, weight: .regular, lineHeight: 1.5, letterSpacing: 0.02)
    static let textSmBold = FontStyle(size: 14, weight: .semibold, lineHeight: 1.5, letterSpacing: 0.02)
    
    static let textMd = FontStyle(size: 18, weight: .regular, lineHeight: 1.5, letterSpacing: 0.01)
    static let textMdBold = FontStyle(size: 18, weight: .semibold, lineHeight: 1.5, letterSpacing: 0.01)
    
    static let text2Xl = FontStyle(size: 32, weight: .regular, lineHeight: 1.2, letterSpacing: -0.01)
    static let text2XlBold = FontStyle(size: 32, weight: .semibold, lineHeight: 1.2, letterSpacing: -0.01)
}

extension Text {
    func setFontStyle(_ fontStyle: FontStyle) -> some View {
        self.font(Font.system(size: fontStyle.size, weight: fontStyle.weight))
            .kerning(fontStyle.size * fontStyle.letterSpacing)
            .frame(height: fontStyle.size * fontStyle.lineHeight)
            .lineLimit(1)
    }
}

struct AppColors {
    static let primary = Color("Primary")
    static let danger = Color("Danger")
    static let textColor = Color("TextColor")
}

struct CryptoLogo: View {
    @State private var _date: Date?
    let image: UIImage?
    var date: Date?
    let size: CGFloat = 30
    
    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .id(_date)
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .opacity.combined(with: .scale(scale: 12))
                        )
                    )
            } else {
                ProgressView()
            }
        }
        .onChange(of: date) {
            withAnimation {
                _date = date
            }
        }
        .frame(width: size, height: size)
    }
}

struct PriceView: View {
    let ticker: TickerCodable?
    let currency: Currency
    let fontStyle: FontStyle
    
    @State private var price: Double?
    
    var body: some View {
        ZStack() {
            let delta = ticker?.delta ?? 0
            let changeColor = delta > 0 ? AppColors.primary : AppColors.danger
            let color = delta == 0 ? AppColors.textColor : changeColor
            
            PriceText
                .foregroundColor(color)
                .transition(.identity)
            PriceText
                .foregroundColor(AppColors.textColor)
                .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .identity
                        )
                )
        }
        .onChange(of: ticker?.price) {
            withAnimation(.timingCurve(0, 0, 1, -1, duration: 0.7)) {
                price = ticker?.price
            }
        }
    }
    
    private var PriceText: some View {
        let text: Text
        if let price = ticker?.price {
            text = Text(AppService.shared.formatFiat(price, currency.rawValue, true))
        } else {
            text = Text(verbatim: "...")
        }
        return text
            .setFontStyle(fontStyle)
            .id(price)
    }
}

struct PriceChangeView: View {
    let ticker: TickerCodable?
    
    var body: some View {
        let text: Text
        if let priceChange = ticker?.price_change_1d {
            text = Text(String(format: "%+.2f%%", priceChange))
                .foregroundColor(priceChange >= 0 ? AppColors.primary : AppColors.danger)
        } else {
            text = Text(verbatim: "...")
        }
        return text
            .setFontStyle(AppFonts.textXsBold)
    }
}
