//
//  NetworkManager.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Alamofire

final class NetworkManager {
    
    static var isReachable: Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    private static let reachabilityManager = Alamofire.NetworkReachabilityManager()
    
    static func startReachabilityObserver() {
        reachabilityManager?.startListening { status in
            switch status {
            case .notReachable:
                print("not reachable")
                NotificationCenter.default.post(name: .networkNotReachable, object: nil)
                AlertManager.showNoInternetConnectionAlert()
            case .reachable(.cellular):
                print("cellular")
                NotificationCenter.default.post(name: .networkReachable, object: nil)
                AlertManager.hideAlert()
            case .reachable(.ethernetOrWiFi):
                print("ethernetOrWiFi")
                NotificationCenter.default.post(name: .networkReachable, object: nil)
                AlertManager.hideAlert()
            default:
                print("unknown")
            }
        }
    }
    
    static func isReachable(showAlertIfNotReachable: Bool = false) -> Bool {
        let reachable = isReachable
        if !reachable && showAlertIfNotReachable {
            AlertManager.showNoInternetConnectionAlert()
        }
        return reachable
    }
}

extension Notification.Name {
    static let networkReachable = Notification.Name(rawValue: "NetworkReachable")
    static let networkNotReachable = Notification.Name(rawValue: "NetworkNotReachable")
}

