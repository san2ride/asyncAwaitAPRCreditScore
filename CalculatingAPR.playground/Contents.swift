import UIKit

enum NetworkError: Error {
    case badUrl
    case decodingError
}

struct CreditScore: Decodable {
    let score: Int
}

struct Constants {
    struct Urls {
        static func equifax(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/equifax/credit-score/\(userId)")
        }
        
        static func experian(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/experian/credit-score/\(userId)")
        }
    }
}

func calculateAPR(creditScores: [CreditScore]) -> Double {
    let sum = creditScores.reduce(0) { next, credit in
        return next + credit.score
    }
    // calculate the APR based on the scores
    return Double((sum/creditScores.count) / 100)
}

func getAPR(userId: Int) async throws -> Double {
    guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
          let experianUrl = Constants.Urls.experian(userId: userId) else {
        throw NetworkError.badUrl
    }
    // two concurrent tasks
    async let (equifaxData, _) = URLSession.shared.data(from: equifaxUrl)
    async let (eperianData, _) = URLSession.shared.data(from: experianUrl)
    
    // custom code
    let equifaxCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await equifaxData)
    let experianCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await eperianData)
    
    guard let equifaxCreditScore = equifaxCreditScore,
          let experianCreditScore = experianCreditScore else {
        throw NetworkError.decodingError
    }
    
    return calculateAPR(creditScores: [equifaxCreditScore, experianCreditScore])
}

/*
// perform a request and give APR
Task.init {
    let apr = try await getAPR(userId: 1)
    print(apr)
}
*/


/*
let ids = [1,2,3,4,5]

Task.init {
    for id in ids {
        let apr = try await getAPR(userId: id)
        print(apr)
    }
}
*/
