//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 15.06.2023.
//

import Foundation

struct AlertModel {
    let title : String
    let message : String
    let buttonText : String
    var completion: () -> Void
}
