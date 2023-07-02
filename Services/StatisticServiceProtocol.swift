//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 01.07.2023.
//

import Foundation

protocol StatisticService {
    func store(newCorrect: Int, newTotal: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}
