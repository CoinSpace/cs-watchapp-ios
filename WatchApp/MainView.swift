import SwiftUI
import WatchConnectivity

enum Route: Hashable {
    case portfolio
    case add
}

struct MainView: View {
    @State private var path = NavigationPath()
    @State private var selectedItem: CryptoItem?
    @State private var scrollToTopTrigger = UUID()
    @State private var reloadTrigger = UUID()
    
    private let delegate: WCSessionDelegate
    private var session: WCSession
    
    @Environment(\.scenePhase) private var scenePhase
    
    init(session: WCSession = .default) {
        self.delegate = SessionDelegater()
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        _ = PortfolioModel.shared
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                if SettingsModel.shared.isLoading {
                    ProgressView()
                } else {
                    if SettingsModel.shared.cryptos.isEmpty {
                        Text("No cryptos").setFontStyle(AppFonts.textMd)
                    } else {
                        ScrollViewReader { proxy in
                            List {
                                EmptyView().id("top")
                                ForEach(SettingsModel.shared.cryptos, id: \.id) { item in
                                    CryptoListItem(cryptoItem: item) {
                                        await SettingsModel.shared.loadPrice(for: item, forceAnimation: true)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            delete(item)
                                        } label: {
                                            Label("Delete", systemImage: "xmark")
                                        }
                                        Button {
                                            showOptions(item)
                                        } label: {
                                            Label("Options", systemImage: "ellipsis")
                                        }
                                    }
                                    .id(item.id.uuidString + reloadTrigger.uuidString)
                                    .task {
                                        await SettingsModel.shared.loadLogo(for: item)
                                        await SettingsModel.shared.loadPrice(for: item)
                                    }
                                }
                                .onMove(perform: move)
                            }
                            .onChange(of: scrollToTopTrigger) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                CurrencyPickerView(selectedCurrency: item.currency, onSelect: { currency in
                    SettingsModel.shared.updateCurrency(for: item, with: currency)
                })
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    reloadTrigger = UUID()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        path.append(Route.add)
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        path.append(Route.portfolio)
                    }) {
                        Image("CoinWallet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .portfolio:
                    PortfolioView()
                case .add:
                    AddView(onAdd: {
                        scrollToTopTrigger = UUID()
                    })
                }
            }
        }
    }
    
    func delete(_ item: CryptoItem) {
        SettingsModel.shared.removeCrypto(item)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        SettingsModel.shared.moveCrypto(from: source, to: destination)
    }

    func showOptions(_ item: CryptoItem) {
        selectedItem = item
    }
}

struct CryptoListItem: View {
    let cryptoItem: CryptoItem
    var size: CGFloat = 30
    let onClick: () async -> Void
        
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
                    CryptoLogo(image: cryptoItem.crypto.image, date: cryptoItem.date)
                    Spacer()
                    PriceChangeView(ticker: cryptoItem.ticker)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(cryptoItem.crypto.name)
                        .setFontStyle(AppFonts.textMd)
                        .foregroundColor(AppColors.textColor)
                    
                    PriceView(ticker: cryptoItem.ticker, currency: cryptoItem.currency, fontStyle: AppFonts.textMdBold)
                        .foregroundColor(AppColors.textColor)
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

class SessionDelegater: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let data = applicationContext["data"] as? String {
            Task { @MainActor in
                PortfolioModel.shared.updatePortfolio(data: data)
            }
        }
    }
}

#Preview {
    MainView()
}
