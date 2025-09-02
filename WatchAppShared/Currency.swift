enum Currency: String, Codable, CaseIterable, Identifiable {
    case AED, ARS, AUD, BDT, BHD,
         BMD, BRL, CAD, CHF, CLP,
         CNY, CZK, DKK, EUR, GBP,
         HKD, HUF, IDR, ILS, INR,
         JPY, KRW, KWD, LKR, MMK,
         MXN, MYR, NGN, NOK, NZD,
         PHP, PKR, PLN, RUB, SAR,
         SEK, SGD, THB, TRY, TWD,
         UAH, USD, VEF, VND, ZAR
    
    var id: String { rawValue }
}
