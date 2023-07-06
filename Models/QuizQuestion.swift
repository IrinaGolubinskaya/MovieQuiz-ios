//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 13.06.2023.
//

import Foundation

struct QuizQuestion {
    ///Строка с названием фильма,
    ///Совпадает с названием картинки афиши фильма в Assets
    let image: Data
    ///строка с вопросом о рейтинге фильма
    let text: String
    ///Булевое значение (true,false), правильный ответ на вопрос
    let correctAnswer: Bool
}

