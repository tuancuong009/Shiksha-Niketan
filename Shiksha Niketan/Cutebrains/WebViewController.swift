//
//  WebViewController.swift
//  Cutebrains
//
//  Created by QTS Coder on 20/05/2024.
//

import UIKit
import WebKit
import Alamofire
import SafariServices
class WebViewController: UIViewController {
    @IBOutlet weak var contentWeb: UIView!
    var web: WKWebView = WKWebView.init()
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewUpdateVersion: UIView!
    @IBOutlet weak var viewSafari: UIView!
    var isLoading = false
    var urlFileDownload: URL?
    var urlFile = ""
    var  docController:UIDocumentInteractionController!
    @IBOutlet weak var viewFlash: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var iconFlash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APP_DELEGATE.webViewVC = self
        addBar()
        setupWebview()
        viewUpdateVersion.isHidden = true
        indicator.startAnimating()
        animationSplash()
        checkVersionUpdate()
        // Do any additional setup after loading the view.
    }

    private func animationSplash(){
        indicator.alpha = 0
        iconFlash.alpha = 0
        iconFlash.transform = .identity // đảm bảo ban đầu không dịch chuyển

        UIView.animate(withDuration:1.5, animations: {
            self.iconFlash.alpha = 1
            self.iconFlash.transform = CGAffineTransform(translationX: 0, y: -40)
        }) { _ in
            UIView.animate(withDuration: 1.0) {
                
            }completion: { success in
                UIView.animate(withDuration: 0.5) {
                    self.viewFlash.alpha = 0.0
                    self.indicator.alpha = 1.0
                }
            }
        }
    }
    func checkVersionUpdate(){
        CheckUpdate.shared.checkVersionUpdate(force: false) { isUpdate in
            print("isUpdate--->",isUpdate)
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: KEY_CHECK_UPDATE_VERSION)
            UserDefaults.standard.synchronize()
            if isUpdate{
                DispatchQueue.main.async {
                    self.viewUpdateVersion.isHidden = false
                }
            }
            else{
                DispatchQueue.main.async {
                    self.viewUpdateVersion.isHidden = true
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        web.frame = CGRect(x: 0, y: 0, width: self.contentWeb.frame.size.width, height: self.contentWeb.frame.size.height)
    }
    
    @IBAction func doBack(_ sender: Any) {
        web.goBack()
    }
    
    func addBar(){
        let statusBarView = UIView()
        view.addSubview(statusBarView)
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            statusBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        statusBarView.backgroundColor = .white
        btnBack.isHidden = true
    }
    
}
extension WebViewController{
    private func setupWebview(){
        self.contentWeb.isHidden = true
        let urlWebsite = SERVER_APP.URL_WEB
        if  let escapedUrlWebsite = urlWebsite.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL.init(string: escapedUrlWebsite){
            print("Urll-->",url.absoluteString)
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true
            configuration.allowsPictureInPictureMediaPlayback = true
            configuration.dataDetectorTypes = .all
            configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
            
            
            let contentController = WKUserContentController()
            configuration.userContentController = contentController
            let wkPreferences = WKPreferences()
            wkPreferences.javaScriptCanOpenWindowsAutomatically = true
            
            configuration.preferences = wkPreferences
            configuration.defaultWebpagePreferences.preferredContentMode = .mobile
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            web = WKWebView(frame: CGRect(x: 0, y: 0, width: self.contentWeb.frame.size.width, height: self.contentWeb.frame.size.height), configuration: configuration)
            web.backgroundColor = .white
            web.allowsBackForwardNavigationGestures = false
            web.clipsToBounds = false
            web.scrollView.clipsToBounds = false
            web.scrollView.backgroundColor = .clear
            web.scrollView.contentInsetAdjustmentBehavior = .never
            web.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Mobile/15E148 Safari/604.1"
            web.navigationDelegate = self
            self.contentWeb.addSubview(web)
            
            
            let request = URLRequest(url:url)
            web.load(request)
        }
    }
    
    
    
    private func saveDeviceToken(_ apiToken: String){
        if !APP_DELEGATE.tokenUser.isEmpty{
            let param = ["api_token": apiToken, "firebase_token": APP_DELEGATE.tokenUser]
            APIHelper.shared.updateDeviceToken(param) { success, errer in
                
            }
        }
    }
    private func hideBtnBack(_ url: String){
        if url.lowercased().contains("jpg") || url.lowercased().contains("png") || url.lowercased().contains("pdf") || url.lowercased().contains("jpeg") || url.lowercased().contains("doc") || url.lowercased().contains("docx"){
            btnBack.isHidden = false
        }
        else{
            btnBack.isHidden = true
        }
    }
}
extension WebViewController: WKDownloadDelegate {
    public func destinationUrlForFile(withName name: String) -> URL? {
        let temporaryDir = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: temporaryDir)
            .appendingPathComponent(UUID().uuidString)
        
        if ((try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)) == nil) {
            return nil
        }
        urlFileDownload = url.appendingPathComponent(name)
        return urlFileDownload
        
        
    }
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        return destinationUrlForFile(withName: suggestedFilename)
    }
    
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        
        DispatchQueue.main.async {
            self.showMessage("Download failed!")
        }
        
        urlFileDownload = nil
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        if let urlFileDownload = urlFileDownload{
            print(urlFileDownload)
            DispatchQueue.main.async {
                self.showMessageCallback("Download Finished", "Do you want to open it?") { success in
                    if success{
                        self.docController = UIDocumentInteractionController(url: urlFileDownload)
                        self.docController.delegate = self
                        self.docController.presentPreview(animated: true)
                    }
                }
            }
            
            
        }
        
    }
    
}
extension WebViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("Dismissed!!!")
        self.docController = nil
    }
}

extension WebViewController: WKNavigationDelegate{
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.contentWeb.isHidden = false
        //introattachment
        self.indicator.alpha = 0.0
        if let url = webView.url {
            hideBtnBack(url.absoluteString)
            if let tokenDefault = UserDefaults.standard.value(forKey: API_TOKEN) as? String{
                webView.getCookies(for: url.host) { data in
                    for dat in data{
                        
                        if dat.key == "api_token"{
                            print(dat.value)
                            
                            if let value = dat.value as? NSDictionary{
                                if let token = value["Value"] as? String, tokenDefault != token{
                                    self.saveDeviceToken(token)
                                    UserDefaults.standard.setValue(token, forKey: API_TOKEN)
                                }
                            }
                            
                        }
                    }
                }
            }
            else{
                webView.getCookies(for: url.host) { data in
                    for dat in data{
                        
                        if dat.key == "api_token"{
                            print("dat.value--->",dat.value)
                            if let value = dat.value as? NSDictionary{
                                if let token = value["Value"] as? String{
                                    self.saveDeviceToken(token)
                                    UserDefaults.standard.setValue(token, forKey: API_TOKEN)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isLoading{
            isLoading = true
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
            // This is not HTTP link - can be a local file or a mailto
            decisionHandler(.cancel)
            return
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download, preferences)
        } else {
            
            decisionHandler(.allow, preferences)
        }
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
         
        if navigationResponse.canShowMIMEType {
            if let urlPath = navigationResponse.response.url{
                let url = urlPath.absoluteString
                if url.lowercased().contains("jpg") || url.lowercased().contains("png") || url.lowercased().contains("pdf") || url.lowercased().contains("jpeg") || url.lowercased().contains("doc") || url.lowercased().contains("docx"){
                    DispatchQueue.main.async {
                        self.showMessageCallback(APP_NAME, "Do you want to download \(urlPath.lastPathComponent)?") { success in
                            if success{
                                self.urlFile = url
                               
                                decisionHandler(.download)
                                
                            }
                            else{
                                decisionHandler(.allow)
                            }
                        }
                    }
                    
                }
                else{
                    decisionHandler(.allow)
                }
            }
            else{
                decisionHandler(.allow)
            }
            
            
        } else {
            
            decisionHandler(.download)
        }
    }
    
    
}
extension WKWebView {
    
    var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    
    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

