//
//  MovieModel.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 22.06.2023.
//

import Foundation

struct Movie: Codable {
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    enum CodingKeys : CodingKey {
        case id
        case title
        case year
        case image
        case releaseDate
        case runtimeMins
        case directors
        case actorList
    }
    
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    init(from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        title = try container.decode(String.self, forKey: .title)
        
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue
        
        image = try container.decode(String.self, forKey: .image)
        
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        
        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMins = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = runtimeMins
        
        directors = try container.decode(String.self, forKey: .directors)
        
        actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}
