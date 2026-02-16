import SwiftUI

struct AddView: View {
    @State private var search = SearchModel()
    @Environment(\.dismiss) private var dismiss
    
    var onAdd: (_ item: CryptoItem) -> Void = {item in }
    
    var body: some View {
        VStack(alignment: .leading) {
            if search.needle.isEmpty {
                Text("Top cryptos").setFontStyle(AppFonts.textMd)
            } else {
                if search.results.isEmpty {
                    Text("No results").setFontStyle(AppFonts.textMd)
                } else {
                    Text("Other cryptos").setFontStyle(AppFonts.textMd)
                }
            }
            
            if search.isLoading {
                ProgressView()
            } else if !search.results.isEmpty {
                ScrollViewReader { proxy in
                    List {
                        EmptyView().id("top")
                        ForEach(search.results, id: \._id) { result in
                            CryptoAddListItem(crypto: result) {
                                let cryptoItem = CryptoItem(crypto: result)
                                SettingsModel.shared.addCrypto(cryptoItem)
                                dismiss()
                                onAdd(cryptoItem)
                            }.task {
                                await search.loadLogo(for: result)
                            }
                        }
                    }.onChange(of: search.needle) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if search.needle.isEmpty {
                    TextFieldLink(prompt: Text("Search")) {
                        Image(systemName: "magnifyingglass")
                    } onSubmit: { userInput in
                        search.needle = userInput
                    }
                    .disabled(search.isLoading)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                } else {
                    Button(action: {
                        search.clear()
                    }) {
                        Image(systemName: "xmark")
                    }.foregroundColor(AppColors.textColor)
                }
            }
        }
    }
}

struct CryptoAddListItem: View {
    var crypto: CryptoCodable
    var size: CGFloat = 30
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 8) {
                ZStack {
                    if let uiImage = crypto.image {
                        Image(uiImage: uiImage).resizable()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: size, height: size)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(crypto.name)
                        .setFontStyle(AppFonts.textMdBold)
                        .foregroundColor(AppColors.textColor)
                    Text(crypto.symbol)
                        .setFontStyle(AppFonts.textSm)
                        .foregroundColor(AppColors.textColor)
                }.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}

#Preview {
    NavigationStack{
        AddView().toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
