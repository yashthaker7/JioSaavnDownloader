//
//  AlertManager.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit
import SwiftMessages

final class AlertManager {
    
    private init() {
    
    }
    
    static private var messageView: MessageView = {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureDropShadow()
        messageView.button?.isHidden = true
        messageView.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        messageView.bodyLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return messageView
    }()
    
    static private var config: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 3.0)
        return config
    }()
    
    class func showSuccessAlert(title: String = "Success", message: String) {
        messageView.configureTheme(.success)
        messageView.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showWarningAlert(title: String = "Warning", message: String) {
        messageView.configureTheme(.warning)
        messageView.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showErrorAlert(title: String = "Error", message: String) {
        messageView.configureTheme(.error)
        messageView.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showServiceErrorAlert(_ serviceError: ServiceError) {
        print(serviceError.localizedDescription)
        showErrorAlert(message: serviceError.localizedDescription)
    }
    
    class func showNoInternetConnectionAlert() {
        showErrorAlert(title: "No Internet Connection!", message: "")
    }
    
    class func hideAlert() {
        SwiftMessages.hide()
    }
    
    class func systemAlert(title: String?, message: String?, positiveTitle: String, parentController: UIViewController, positiveActionHandler: @escaping () -> ()) {
        let alertVC = createAlertController(title: title, message: message)
        let positiveAction = UIAlertAction(title: positiveTitle, style: .default, handler: { _ in
            positiveActionHandler()
        })
        alertVC.addAction(positiveAction)
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    class func systemAlert(title: String?, message: String?, negativeTitle: String, positiveTitle: String, parentController: UIViewController, negativeActionHandler: @escaping () -> (), positiveActionHandler: @escaping () -> ()) {
        let alertVC = createAlertController(title: title, message: message)
        let negativeAction = UIAlertAction(title: negativeTitle, style: .default, handler: { action in
            negativeActionHandler()
        })
        let positiveAction = UIAlertAction(title: positiveTitle, style: .default, handler: { _ in
            positiveActionHandler()
        })
        alertVC.addAction(negativeAction)
        alertVC.addAction(positiveAction)
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    class private func createAlertController(title: String?, message: String?) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alertVC
    }
}

