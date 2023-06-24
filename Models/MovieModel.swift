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
    let year: String
    let image: String
    let releaseDate: String
    let runtimeMins: String
    let directors: String
    let actorList: [Actor]
}
