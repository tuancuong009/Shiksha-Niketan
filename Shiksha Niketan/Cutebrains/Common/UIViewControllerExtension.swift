//
//  UIViewControllerExtension.swift
//  Cutebrains
//
//  Created by QTS Coder on 23/05/2024.
//

import UIKit
extension UIViewController{
    func showMessage( _ message: String){
        let alertVC = UIAlertController.init(title: APP_NAME, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "OK", style: .cancel) { action in
            
        }
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true) {
            
        }
    }
    
    func showMessageCallback(_ title: String = APP_NAME, _ message: String, complete:@escaping (_ success: Bool) ->Void){
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "No", style: .cancel) { action in
            complete(false)
        }
        alertVC.addAction(cancelAction)
        
        let noAction = UIAlertAction.init(title: "Yes", style: .default) { action in
            complete(true)
        }
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true) {
            
        }
    }
}
