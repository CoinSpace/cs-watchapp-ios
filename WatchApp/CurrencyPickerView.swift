import SwiftUI

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
