import Foundation

struct CryptoItem: Identifiable, Codable {
    var id: String {
        crypto.asset
    }
    var crypto: CryptoCodable
    var ticker: TickerCodable?
    var currency: Currency = .USD
    var date = Date()
}
