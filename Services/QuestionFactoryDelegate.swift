//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 14.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
