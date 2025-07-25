//
//  CheckUpdate.swift
//  CheckApp
//
//  Created by Ana Carolina on 13/11/20.
//  Copyright © 2020 acarolsf. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Enum Errors
enum VersionError: Error {
    case invalidBundleInfo, invalidResponse, dataError
}

// MARK: - Models
struct LookupResult: Decodable {
    let data: [TestFlightInfo]?
    let results: [AppInfo]?
}

struct TestFlightInfo: Decodable {
    let type: String
    let attributes: Attributes
}

struct Attributes: Decodable {
    let version: String
    let expired: String
}

struct AppInfo: Decodable {
    let version: String
    let trackViewUrl: String
}


// MARK: - Check Update Class
class CheckUpdate: NSObject {

    // MARK: - Singleton
    static let shared = CheckUpdate()

    // MARK: - TestFlight variable
    var isTestFlight: Bool = false

    static let appStoreId = "6499132466" // Id Example
    
    // MARK: - Show Update Function
    func showUpdate(withConfirmation: Bool, isTestFlight: Bool = false) {
        self.isTestFlight = isTestFlight
        DispatchQueue.global().async {
            self.checkVersion(force : !withConfirmation)
        }
    }

    // MARK: - Function to check version
    private  func checkVersion(force: Bool) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (data, info, error) in
                
                let store = self .isTestFlight ? "TestFlight" : "AppStore"
                
                if let error = error {
                    print("error getting app \(store) version: ", error)
                }
                
                if let appStoreAppVersion = info?.version { // Check app on AppStore
                    // Check if the installed app is the same that is on AppStore, if it is, print on console, but if it isn't it shows an alert.
                    print("appStoreAppVersion--->",appStoreAppVersion,currentVersion)
                    if appStoreAppVersion <= currentVersion {
                        print("Already on the last app version: ", currentVersion)
                    } else {
                        print("Needs update: \(store) Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                        DispatchQueue.main.async {
                            let topController: UIViewController = (UIApplication.shared.windows.first?.rootViewController)!
                            topController.showAppUpdateAlert(version: appStoreAppVersion, force: force, appURL: (info?.trackViewUrl)!, isTestFlight: self.isTestFlight)
                        }
                    }
                } else if let testFlightAppVersion = data?.attributes.version { // Check app on TestFlight
                // Check if the installed app is the same that is on TestFlight, if it is, print on console, but if it isn't it shows an alert.
                    if testFlightAppVersion <= currentVersion {
                        print("Already on the last app version: ",currentVersion)
                    } else {
                        print("Needs update: \(store) Version: \(testFlightAppVersion) > Current version: ", currentVersion)
                        DispatchQueue.main.async {
                            let topController: UIViewController = (UIApplication.shared.windows.first?.rootViewController)!
                            topController.showAppUpdateAlert(version: testFlightAppVersion, force: force, appURL: (info?.trackViewUrl)!, isTestFlight: self.isTestFlight)
                        }
                    }
                }  else { // App doesn't exist on store
                    print("App does not exist on \(store)")
                }
            }
        } else {
            print("Erro to decode app current version")
        }
    }
    
    private func getUrl(from identifier: String) -> String {
        // You should pay attention on the country that your app is located, in my case I put Brazil */br/*
        // Você deve prestar atenção em que país o app está disponível, no meu caso eu coloquei Brasil */br/*
        let testflightURL = "https://api.appstoreconnect.apple.com/v1/apps/\(CheckUpdate.appStoreId)/builds"
        let appStoreURL = "http://itunes.apple.com/in/lookup?bundleId=\(identifier)"

        return isTestFlight ? testflightURL : appStoreURL
    }

    func getAppInfo(completion: @escaping (TestFlightInfo?, AppInfo?, Error?) -> Void) -> URLSessionDataTask? {

        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: getUrl(from: identifier)) else {
                DispatchQueue.main.async {
                    completion(nil, nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        
        // You need to generate an authorization token to access the TestFlight versions and then you replace the ```***``` with the JWT token.
        // Você precisa gerar um token de autorização para acessar as versões de TestFlight e depois você substitui o ```***``` com o token JWT gerado.
        // https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
        
        let authorization = "Bearer ***"
        
        var request = URLRequest(url: url)
        print("url--->",url)
        // You just need to add an authorization header if you are checking TestFlight version
        // Você só precisa adicionar uma autorização no header se você está checando a versão de testflight
        if self.isTestFlight {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        // Make request
        // Fazer a requisição
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                do {
                    if let error = error {
                        print(error)
                        throw error
                    }
                    guard let data = data else { throw VersionError.invalidResponse }
                 
                    let result = try JSONDecoder().decode(LookupResult.self, from: data)
                   
                    
                    if self.isTestFlight {
                        let info = result.data?.first
                        completion(info, nil, nil)
                    } else {
                        print("result.results--->",result.results)
                        let info = result.results?.first
                        print("info--->",info)
                        completion(nil, info, nil)
                    }

                } catch {
                    completion(nil, nil, error)
                }
            }
        
        task.resume()
        return task

    }

    func getBundle(key: String) -> String? {

        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Info.plist'.")
        }
        // Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
    
    func checkVersionUpdate(force: Bool, complete:@escaping (_ isUpdate: Bool) ->Void){
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (data, info, error) in
                
                let store = self .isTestFlight ? "TestFlight" : "AppStore"
                
                if let error = error {
                    print("error getting app \(store) version: ", error)
                }
                
                if let appStoreAppVersion = info?.version { // Check app on AppStore
                    // Check if the installed app is the same that is on AppStore, if it is, print on console, but if it isn't it shows an alert.
                    if appStoreAppVersion <= currentVersion {
                        print("Already on the last app version: ", currentVersion)
                        complete(false)
                    } else {
                        print("Needs update: \(store) Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                        complete(true)
                    }
                } else if let testFlightAppVersion = data?.attributes.version { // Check app on TestFlight
                // Check if the installed app is the same that is on TestFlight, if it is, print on console, but if it isn't it shows an alert.
                    if testFlightAppVersion <= currentVersion {
                        print("Already on the last app version: ",currentVersion)
                        complete(false)
                    } else {
                        print("Needs update: \(store) Version: \(testFlightAppVersion) > Current version: ", currentVersion)
                        complete(true)
                    }
                }  else { // App doesn't exist on store
                    print("App does not exist on \(store)")
                    complete(false)
                }
            }
        } else {
            complete(false)
            print("Erro to decode app current version")
        }
    }
    
}

// MARK: - Show Alert
extension UIViewController {
    @objc fileprivate func showAppUpdateAlert(version : String, force: Bool, appURL: String, isTestFlight: Bool) {
        guard let appName = CheckUpdate.shared.getBundle(key: "CFBundleName") else { return } //Bundle.appName()

        let alertTitle = "New version"
        let alertMessage = "A new version of \(appName) is available on \(isTestFlight ? "TestFlight" : "AppStore"). Update now!"

        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if !force {
            let notNowButton = UIAlertAction(title: "Not now", style: .default)
            alertController.addAction(notNowButton)
        }

        let updateButton = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: appURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

