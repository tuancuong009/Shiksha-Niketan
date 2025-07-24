//
//  UpdateVersionVC.swift
//  Cutebrains
//
//  Created by QTS Coder on 22/05/2024.
//

import UIKit

class UpdateVersionVC: UIViewController {

    @IBOutlet weak var btnUpdateVersion: UIButton!
    @IBOutlet weak var lblNote: UILabel!
    override func viewDidLoad() {
        btnUpdateVersion.layer.cornerRadius = 10
        btnUpdateVersion.layer.masksToBounds = true
        _ = CheckUpdate.shared.getAppInfo { (data, info, error) in
            if let appStoreAppVersion = info?.version {
                DispatchQueue.main.async {
                    self.lblNote.text = "A new version \(appStoreAppVersion) of the app is available. \nUpdate to enjoy the latest features and improvements."
                }
                
            }
        }
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doUpdateVersion(_ sender: Any) {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/\(APP_ID)?mt=8"
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
    }
}
