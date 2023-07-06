//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 01.07.2023.
//

import Foundation
///тип данных, в который мы будем записывать лучший результат игры
struct GameRecord: Codable {
    ///количество правильных ответов в 1 игре
    let correct: Int
    ///количество всех правильных вопросов за все игры
    let total: Int
    ///дата завершения раунда
    let date: Date
}

///расширение для структуры Gamerecord,которое позволяет сравнивать экземпляры структуры( результаты  игр)
extension GameRecord: Comparable {
    
    static func > (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct > rhs.correct
    }
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    
    static func <= (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct <= rhs.correct
    }
    
    static func >= (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct >= rhs.correct
    }
    
}
