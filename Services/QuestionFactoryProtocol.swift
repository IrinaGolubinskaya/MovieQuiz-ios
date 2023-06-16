//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 14.06.2023.
//

import Foundation
/// протокол, который возвращает вопрос для квиза
protocol QuestionFactoryProtocol {
    ///метод, который возвращает вопрос для квиза
    func requestNextQuestion() 
}
