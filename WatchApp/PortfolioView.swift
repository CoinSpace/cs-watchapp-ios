import SwiftUI

struct PortfolioView: View {
    @State private var text = ""
        @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        List {
            CryptoListItem()
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        showOptions()
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                    }
                }
        }.scrollDisabled(true)
        }
    
    func showOptions() {
        print("Options tapped")
        // Add your logic here (e.g., navigate or present a sheet)
    }
}

#Preview {
    PortfolioView()
}
