//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 15.06.2023.
//

import UIKit

final class AlertPresenter {
    
    weak var delegate : AlertShowDelegate?
    
    func getAlert(alertModel: AlertModel) {
        //создаём объекты всплывающего окна
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        //создаём для алерта кнопку с действием
        //в замыкании пишем, что должно происходить при нажатии на кнопку
        alert.view.accessibilityIdentifier = "Game Results"
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction (action)
        
        delegate?.show(alert: alert)
    }
}
