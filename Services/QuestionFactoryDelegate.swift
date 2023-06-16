//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 14.06.2023.
//

import Foundation
///протокол, который принимает вопрос
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
