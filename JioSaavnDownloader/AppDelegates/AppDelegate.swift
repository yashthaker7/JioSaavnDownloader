//
//  AppDelegate.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NetworkManager.startReachabilityObserver()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppDelegate.handleIncomingURL(url)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    class func handleIncomingURL(_ url: URL) {
        guard let scheme = url.scheme, scheme.caseInsensitiveCompare("JioSaavnDownloaderShareExtension") == .orderedSame,
              let page = url.host else { return }
        var parameters = [String: String]()
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        print("redirect(to: \(page), with: \(parameters))")
        for parameter in parameters where parameter.key.caseInsensitiveCompare("url") == .orderedSame {
            UserDefaults().set(parameter.value, forKey: "incomingURL")
        }
    }
}

