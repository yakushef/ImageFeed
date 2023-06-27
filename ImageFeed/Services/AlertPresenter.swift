//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 19.06.2023.
//

import UIKit

protocol AlertPresenterDelegate {

//    var alertPresenter: AlertPresenterProtocol! { get <#set#> }
//
    func show(alert: UIAlertController)
}

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate { get }
    func presentAlert(title: String, message: String, buttonText: String, completion: @escaping () -> Void)
}

final class AlertPresenter: AlertPresenterProtocol {
    let delegate: AlertPresenterDelegate
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentAlert(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { _ in
            completion()
        }
        alert.addAction(action)
        delegate.show(alert: alert)
    }
}
