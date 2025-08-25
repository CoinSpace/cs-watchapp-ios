import Foundation
import UIKit

actor ApiClient {
    
    static let shared = ApiClient()
    
    private var cache: [String: CacheEntryObject] = [:]
    private let API_PRICE_URL: String = "https://price.coin.space/"
    
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
        
        let key = "prices:\(cryptoIds.joined(separator: ",")):\(fiat)"
        let defaults = UserDefaults.standard
        var oldTickers: [TickerCodable] = []
        if let data = defaults.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode([TickerCodable].self, from: data) {
                oldTickers = decoded
            }
        }
        if let encoded = try? JSONEncoder().encode(allTickers) {
            defaults.set(encoded, forKey: key)
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
        let cacheKey: String = url
        if let cached = cache[cacheKey] {
            switch cached.entry {
            case .ready(let value, let timestamp):
                if Date().timeIntervalSince(timestamp) < ttl {
                    return value as! T
                } else {
                    cache[cacheKey] = nil
                }
            case .inProgress(let task):
                return try await task.value as! T
            }
        }
        let task = Task<Any, Error> {
            print("API call: \(url)")
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            let result = try JSONDecoder().decode(T.self, from: data)
            return completion(result)
        }
        cache[cacheKey] = CacheEntryObject(.inProgress(task))
        do {
            let value = try await task.value
            cache[cacheKey] = CacheEntryObject(.ready(value as! T, Date()))
            return value as! T
        } catch {
            cache[cacheKey] = nil
            print("API Error", error)
            throw ApiError()
        }
    }
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

final class CacheEntryObject {
    let entry: CacheEntry
    init(_ entry: CacheEntry) {
        self.entry = entry
    }
}

enum CacheEntry {
    case inProgress(Task<Any, Error>)
    case ready(Any, Date)
}
