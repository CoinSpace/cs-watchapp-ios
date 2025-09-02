import SwiftUI

struct PortfolioView: View {
    
    @State private var path = NavigationPath()
    @State private var selectedItem: Portfolio?
    @State private var reloadTrigger = UUID()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showAlert = false
    
    var body: some View {
            
        ZStack {
            if PortfolioModel.shared.isLoading {
                ProgressView()
            } else {
                List {
                    let portfolio = PortfolioModel.shared.portfolio
                    if portfolio.isLogged {
                        PortfolioListItem(portfolio: portfolio) {
                                    await PortfolioModel.shared.loadPrice(forceAnimation: true)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    showOptions(portfolio)
                                } label: {
                                    Label("Options", systemImage: "ellipsis")
                                }
                            }
                            .id(portfolio.id.uuidString + reloadTrigger.uuidString)
                            .task {
                                await PortfolioModel.shared.loadPrice()
                            }
                    } else {
                        PortfolioListItem() {
                            showAlert = true
                        }.alert("Sign In Required", isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Please open Coin Wallet on your iPhone to sign in.")
                        }
                    }
                }.scrollDisabled(true)
            }
        }
        .sheet(item: $selectedItem) { item in
            CurrencyPickerView(selectedCurrency: item.currency, onSelect: { currency in
                PortfolioModel.shared.updateCurrency(with: currency)
            })
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                reloadTrigger = UUID()
            }
        }
    }
    
    func showOptions(_ item: Portfolio) {
        selectedItem = item
    }
}

struct PortfolioListItem: View {
    var portfolio: Portfolio?
    var size: CGFloat = 30
    var onClick: () async -> Void
    @State private var date = Date()
    
    private var clipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16)
    }

    var body: some View {
        Button {
            Task {
                await onClick()
            }
        } label: {
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    CryptoLogo(image: UIImage(named: "CoinWallet"), date: portfolio?.date)
                    Spacer()
                    if let ticker = portfolio?.total {
                        PriceChangeView(ticker: ticker)
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Portfolio")
                        .setFontStyle(AppFonts.textMd)
                        .foregroundColor(AppColors.textColor)
                    if let portfolio = portfolio {
                        PriceView(
                            ticker: portfolio.total,
                            currency: portfolio.currency,
                            fontStyle: AppFonts.textMdBold,
                            customFractionDigits: false
                        ).foregroundColor(AppColors.textColor)
                    } else {
                        Text("Sign In")
                            .setFontStyle(AppFonts.textMdBold)
                    }
                }.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }.padding(8)
        }
        .listRowBackground(clipShape.fill(.background.secondary))
        .clipShape(clipShape)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    NavigationStack{
        PortfolioView().toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
