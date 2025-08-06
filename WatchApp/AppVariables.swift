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

struct CryptoListItem: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                Circle().fill(.orange)
                    .frame(width: 30, height: 30)
                Spacer()
                Text("+3.43%")
                    .setFontStyle(AppFonts.textXsBold)
                    .foregroundColor(AppColors.primary)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Bitcoin")
                    .setFontStyle(AppFonts.textMd)
                    .foregroundColor(AppColors.textColor)
                Text("$1,938,638.36")
                    .setFontStyle(AppFonts.textMdBold)
                    .foregroundColor(AppColors.textColor)
            }.frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}

struct CryptoAddListItem: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(.orange)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 0) {
                Text("Ethereum")
                    .setFontStyle(AppFonts.textMdBold)
                    .foregroundColor(AppColors.textColor)
                Text("ETH")
                    .setFontStyle(AppFonts.textSm)
                    .foregroundColor(AppColors.textColor)
            }.frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}
