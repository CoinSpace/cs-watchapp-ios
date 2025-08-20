import SwiftUI

enum Currency: String, Codable, CaseIterable, Identifiable {
    case AED, ARS, AUD, BDT, BHD,
         BMD, BRL, CAD, CHF, CLP,
         CNY, CZK, DKK, EUR, GBP,
         HKD, HUF, IDR, ILS, INR,
         JPY, KRW, KWD, LKR, MMK,
         MXN, MYR, NGN, NOK, NZD,
         PHP, PKR, PLN, RUB, SAR,
         SEK, SGD, THB, TRY, TWD,
         UAH, USD, VEF, VND, ZAR
    
    var id: String { rawValue }
}

struct CurrencyPickerView: View {
    @State var selectedCurrency: Currency = .USD
    @Environment(\.dismiss) private var dismiss
    var onSelect: (Currency) -> Void = {_ in }

    var body: some View {
        NavigationView {
            List {
                Picker("Local currency", selection: $selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: selectedCurrency) {
                    onSelect(selectedCurrency)
                    dismiss()
                }
            }
            .navigationTitle("Options")
        }
    }
}

#Preview {
    CurrencyPickerView()
}
