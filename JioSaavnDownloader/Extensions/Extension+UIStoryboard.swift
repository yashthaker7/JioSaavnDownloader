//
//  Extension+UIStoryboard.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit

protocol TYStoryboardIdentifiable: TYIdentifiable { }
extension UIViewController: TYStoryboardIdentifiable { }

extension UIStoryboard {

    enum Storyboard: String {
        case main       = "Main"
        
        var fileName: String {
            return rawValue
        }
    }
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.fileName, bundle: bundle)
    }
    
    func instantiateVC<T: UIViewController>() -> T {
        guard let viewController = instantiateViewController(identifier: T.identifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.identifier) ")
        }
        return viewController
    }
}

