import SwiftUI

import WatchKit

struct CryptoItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
}

enum Route: Hashable {
    case portfolio
    case addCrypto
}

struct ContentView: View {
    @State private var items: [CryptoItem] = [
        CryptoItem(title: "Item 1"),
        CryptoItem(title: "Item 2"),
        CryptoItem(title: "Item 3"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
        CryptoItem(title: "Item 4"),
    ]
    
    @State private var path = NavigationPath()
    
    @State private var showSearch: Bool = false
    @State private var inputText: String = ""
    
    @State private var showSearchView = false
    
//    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var text = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(items) { item in
                    CryptoListItem()
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                delete(item)
                            } label: {
                                Label("Delete", systemImage: "xmark")
                            }
                            Button {
                                showOptions(for: item)
                            } label: {
                                Label("Options", systemImage: "ellipsis")
                            }
                        }
                }
                .onMove(perform: move)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        path.append(Route.addCrypto)
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
                case .addCrypto:
                    AddCryptoView()
                }
            }
        }
    }
    
    func delete(_ item: CryptoItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    func showOptions(for item: CryptoItem) {
        print("Options tapped for \(item.title)")
        // Add your logic here (e.g., navigate or present a sheet)
    }
    
    func presentScribbleInput() {
        WKApplication.shared().visibleInterfaceController?.presentTextInputController(withSuggestions: ["Bitcoin", "Litecoin", "Monero", "Solana"], allowedInputMode: .plain) { contentArray in
            if let contentArray, let userInput = contentArray.first as? String, !userInput.isEmpty {
                print("userInput:" + userInput)
            } else if contentArray == nil {
                // User hit the cancel button
                print("user hit the cancel button")
            } else {
                // User hit the done button without typing anything
                print("user hit the done button without typing anything")
            }
        }
    }
}

#Preview {
    ContentView()
}
