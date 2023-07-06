//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 13.06.2023.
//

import Foundation
import UIKit

struct QuizStepViewModel {
    ///картинка с афишей фильма с типом UIImage
    let image : UIImage
    ///вопрос о рейтинге квиза
    let question: String
    ///строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}
