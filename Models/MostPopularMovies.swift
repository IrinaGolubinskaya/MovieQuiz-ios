//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 05.07.2023.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
    
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating =  "imDbRating"
        case imageURL = "image"
    }
    
    var resizedImageURL: URL {
        //создаём строку из адреса
        let urlString = imageURL.absoluteString
        //обрезаем лишнюю часть и добавляем модификатор желаемого качества
        let imageURLString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        //пытаемся создать новый адрес или возвращаем старый
        guard let NewURL = URL(string: imageURLString) else {
            return imageURL
        }
        return NewURL
    }
    
    private enum ParseError: Error{
        case ratingFailure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.rating = try container.decode(String.self, forKey: .rating)
        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
    }
}
