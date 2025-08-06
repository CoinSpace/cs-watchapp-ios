import SwiftUI

struct AddCryptoView: View {
    @State private var needle = ""
    @State private var results = ["bitcoin"]
    
    var body: some View {
        VStack(alignment: .leading) {
            if needle.isEmpty {
                Text("Top cryptos").setFontStyle(AppFonts.textMd)
            } else {
                if results.isEmpty {
                    Text("No results").setFontStyle(AppFonts.textMd)
                } else {
                    Text("Other cryptos").setFontStyle(AppFonts.textMd)
                }
            }
            
            if !results.isEmpty {
                List {
                    CryptoAddListItem()
                    CryptoAddListItem()
                    CryptoAddListItem()
                    CryptoAddListItem()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if needle.isEmpty {
                    TextFieldLink(prompt: Text("Search")) {
                        Image(systemName: "magnifyingglass")
                    } onSubmit: { userInput in
                        needle = userInput
                        results = []
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                } else {
                    Button(action: {
                        needle = ""
                        results = ["bitcoin"]
                    }) {
                        Image(systemName: "xmark")
                    }.foregroundColor(AppColors.textColor)
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        AddCryptoView().toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
