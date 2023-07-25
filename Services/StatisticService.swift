//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 27.06.2023.
//

import Foundation

///класс, который сохраняет модели рекордов и передаёт их в alert для показа текста с лучшим результатом
final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private var userDefaults = UserDefaults.standard
    ///переменная с количеством ВСЕХ вопросов
    private var total: Int {
        return userDefaults.integer(forKey: Keys.total.rawValue)
    }
    
    ///переменная с количеством ВСЕХ правильных ответов
    private var correct: Int {
        return userDefaults.integer(forKey: Keys.correct.rawValue)
    }
    
    //среднее арифмитическое всех игр
    var totalAccuracy: Double {
        get {
            let allAnswers = Double(userDefaults.integer(forKey: Keys.total.rawValue))
            let allCorrectAnswers = Double(userDefaults.integer(forKey: Keys.correct.rawValue))
            return 100 * (allCorrectAnswers / allAnswers)
        }
    }
    
    private(set) var gamesCount: Int {
        get {
            let countOfGames = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return countOfGames
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            //достаём значение модели лучшей игры из userDefaults в формате "Дата":
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  // полученное значение модели переводим в модель GameRecord:
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                //если не получается, то возвращаем экземпляр структуры с нулевыми параметрами и текущей датой:
                return .init(correct: 0, total: 0, date: Date())
            }
            //возвращаем  модель рекорда
            return record
        }
        set {
            //новое значение record переводим в формат Дата:
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранит результат")
                return
            }
            // сохраняем в  userDefaults модель рекорда
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    ///функцию сохранения лучшего результата store (с проверкой на то, что новый результат лучше сохранённого в User Defaults
    func store(newCorrect: Int, newTotal: Int) {
        gamesCount += 1
        userDefaults.set(self.total + newTotal , forKey: Keys.total.rawValue)
        userDefaults.set(self.correct + newCorrect, forKey: Keys.correct.rawValue)
        
        //создаём результат игры
        let newRecord = GameRecord(correct: newCorrect, total: newTotal, date: Date())
        
        //сравниваем результат игры и лучший результат
        if newRecord > bestGame {
            bestGame = newRecord
        }
    }
}
