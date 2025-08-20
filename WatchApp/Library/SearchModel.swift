import SwiftUI

@MainActor
@Observable
class SearchModel {
    private var allCryptos: [CryptoCodable] = []
    
    var results: [CryptoCodable] = []
    var needle: String = "" {
        didSet {
            filterResults()
        }
    }
    var isLoading: Bool = true
    
    init() {
        Task {
            allCryptos = try await ApiClient.shared.cryptos()
            filterResults()
            isLoading = false
        }
    }
    
    private func filterResults() {
        let filtered = (needle.isEmpty ? allCryptos : allCryptos.filter {
            "\($0.name) \($0.symbol)".localizedCaseInsensitiveContains(needle)
        }).prefix(10)
        results = Array(filtered)
    }

    func clear() {
        needle = ""
    }
    
    func loadLogo(for crypto: CryptoCodable) async {
        guard crypto.image == nil else { return }
        let image = await CryptoCodable.loadImage(crypto)
        guard let index = results.firstIndex(where: { $0._id == crypto._id }) else { return }
        results[index].image = image
    }
}
