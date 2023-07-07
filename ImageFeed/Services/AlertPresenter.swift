//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 19.06.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(alert: UIAlertController)
}

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? { get }
    func presentAlert(alert: UIAlertController)
    func presentAlert(title: String, message: String, buttonText: String, completion: @escaping () -> Void)
}

final class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentAlert(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { _ in
            completion()
        }
        
        guard let delegate = delegate else { return }
        
        alert.addAction(action)
        delegate.show(alert: alert)
    }
    
    func presentAlert(alert: UIAlertController) {
        guard let delegate = delegate else { return }
        
        delegate.show(alert: alert)
    }
}
