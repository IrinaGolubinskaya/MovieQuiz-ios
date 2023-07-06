//
//  MovieModel.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 22.06.2023.
//

import Foundation

struct Movie: Codable {
    let id : String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating : Double
    let imDbRatingCount: Int
    
    enum CodingKeys : CodingKey {
        case id
        case rank
        case title
        case fullTitle
        case year
        case image
        case crew
        case imDbRating
        case imDbRatingCount
    }
    
    enum ParseError: Error {
        case yearFailure
        case rankFailure
        case imDbRatingFailure
        case imDbRatingCount
    }
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        
        self.rank = rankValue
        
        title = try container.decode(String.self, forKey: .title)
        
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        
        let year = try container.decode(String.self, forKey: .year)
        guard let yeraValue = Int(year) else {
            throw ParseError.yearFailure
        }
        
        self.year = yeraValue
        
        image = try container.decode(String.self, forKey: .image)
        
        crew = try container.decode(String.self, forKey: .crew)
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let imDbRatingValue = Double(imDbRating) else {
            throw ParseError.imDbRatingFailure
        }
        
        self.imDbRating = imDbRatingValue
        
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let imDbRatingCountValue = Int(imDbRatingCount) else {
            throw ParseError.imDbRatingFailure
        }
        
        self.imDbRatingCount = imDbRatingCountValue
    }
}
