import Foundation
import UIKit

actor ApiClient {
    
    static let shared = ApiClient()
    
    private let API_PRICE_URL: String = "https://price.coin.space/"
    private let suiteName = "group.com.coinspace.shared"
    
    private var prices: [String: Double] = [:]
    
    func cryptos(uniqueAssets: Bool = true) async throws -> [CryptoCodable] {
        let cryptos: [CryptoCodable] = try await self.call("\(API_PRICE_URL)api/v1/cryptos", ttl: 12.0 * 60 * 60) { result in
            let filtered: [CryptoCodable] = result.compactMap { item -> CryptoCodable? in
                guard item.logo != nil else { return nil }
                guard item.deprecated != true else { return nil }
                var crypto = item
                crypto.logo = NSString(string: item.logo!).deletingPathExtension + ".png"
                return crypto
            }
            return filtered
        }
        
        if uniqueAssets {
            var dict = Set<String>()
            return cryptos.filter { dict.insert($0.asset).inserted }
        }
        return cryptos
    }
    
    func prices(_ cryptoIds: [String], _ fiat: String) async throws -> [TickerCodable] {        
        let chunkSize = 30
        let chunks = stride(from: 0, to: cryptoIds.count, by: chunkSize).map {
            Array(cryptoIds[$0..<min($0 + chunkSize, cryptoIds.count)])
        }
        var allTickers: [TickerCodable] = []
        
        for chunk in chunks {
            let url = "\(API_PRICE_URL)api/v1/prices/public?fiat=\(fiat)&cryptoIds=\(chunk.joined(separator: ","))"
            let tickers: [TickerCodable] = try await self.call(url, ttl: 60)
            allTickers.append(contentsOf: tickers)
        }
        
        var oldTickers: [TickerCodable] = []
        if let defaults = UserDefaults(suiteName: self.suiteName) {
            let key = "prices:\(cryptoIds.joined(separator: ",")):\(fiat)"
            if let data = defaults.data(forKey: key) {
                if let decoded = try? JSONDecoder().decode([TickerCodable].self, from: data) {
                    oldTickers = decoded
                }
            }
            if let encoded = try? JSONEncoder().encode(allTickers) {
                defaults.set(encoded, forKey: key)
            }
        }
        
        return cryptoIds.compactMap { cryptoId in
            var ticker = allTickers.first(where: { $0.cryptoId == cryptoId })
            if let oldTicker = oldTickers.first(where: { $0.cryptoId == cryptoId }), let price = ticker?.price {
                ticker?.delta = price - oldTicker.price
            }
            return ticker
        }
    }
    
    func call<T: Codable>(_ url: String, ttl: TimeInterval = 0, completion: @escaping (T) -> T = { $0 }) async throws -> T {
        let cacheKey: String = "cache:\(url)"
        
        if let defaults = UserDefaults(suiteName: self.suiteName),
           let data = defaults.data(forKey: cacheKey),
           let cachedEntry = try? JSONDecoder().decode(CacheEntryCodable.self, from: data) {
            
            if Date().timeIntervalSince(cachedEntry.timestamp) < ttl {
                if let decoded = try? JSONDecoder().decode(T.self, from: cachedEntry.value) {
                    return decoded
                }
            } else {
                defaults.removeObject(forKey: cacheKey)
            }
        }
        
        do {
            print("API call: \(url)")
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            let result = try JSONDecoder().decode(T.self, from: data)
            let final = completion(result)
            
            if let defaults = UserDefaults(suiteName: self.suiteName),
               let encodedValue = try? JSONEncoder().encode(final) {
                let entry = CacheEntryCodable(value: encodedValue, timestamp: Date())
                if let encodedEntry = try? JSONEncoder().encode(entry) {
                    defaults.set(encodedEntry, forKey: cacheKey)
                }
            }
            return final
        } catch {
            if let error = error as? URLError, error.code != .cancelled {
                print("API Error", error)
            }
            throw ApiError()
        }
    }
}

struct CacheEntryCodable: Codable {
    let value: Data
    let timestamp: Date
}

struct ApiError: Error {}

protocol CryptoDisplayable {
    var logo: String? { get }
    var image: UIImage? { get set }
}

struct CryptoCodable: Codable, CryptoDisplayable {
    let asset: String
    let _id: String
    let type: String
    let name: String
    let symbol: String
    let deprecated: Bool
    var logo: String?
    
    enum CodingKeys: String, CodingKey {
        case asset
        case _id
        case type
        case name
        case symbol
        case deprecated
        case logo
    }
    
    var image: UIImage?
    
    static let bitcoin = CryptoCodable(asset: "bitcoin", _id: "bitcoin@bitcoin", type: "coin", name: "Bitcoin", symbol: "BTC", deprecated: false, logo: "bitcoin.png", image: UIImage(named: "Bitcoin"))
    
    static func loadImage(_ item: CryptoCodable) async -> UIImage? {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        return await AppService.shared.downloadImage(url: "https://price.coin.space/logo/\(item.logo!)?ver=\(version)")
    }
}

struct TickerCodable: Codable {
    let cryptoId: String
    let price: Double
    let price_change_1d: Double?
    
    enum CodingKeys: String, CodingKey {
        case cryptoId, price, price_change_1d
    }
    
    var delta: Double?
    
    static let bitcoin = TickerCodable(cryptoId: "bitcoin@bitcoin", price: 1000000, price_change_1d: 100)
    
    static func bitcoins(size: Int) -> [TickerCodable] {
        Array(repeating: self.bitcoin, count: size)
    }
}
