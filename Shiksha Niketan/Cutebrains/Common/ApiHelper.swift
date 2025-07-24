//
//  ApiHelper.swift
//  Sully.ai
//
//  Created by QTS Coder on 05/03/2024.
//

import Alamofire
class APIHelper {
    static let shared = APIHelper()
    private let auth_headerLogin: HTTPHeaders    = ["Content-Type": "application/json"]

    
    func updateDeviceToken(_ param: Parameters, complete:@escaping (_ success: Bool?, _ errer: String?) ->Void)
    {
    
        print("URL--->",SERVER_APP.URL_SERVER + "/api/device-tokens.php")
        print("Param--->",param)
        AF.request(URL.init(string: SERVER_APP.URL_SERVER + "/api/device-tokens.php")!, method: .post, parameters: param,  encoding: JSONEncoding.default, headers: auth_headerLogin)
            .responseJSON { response in
                print(response)
                switch(response.result) {
                case .success(_):
                    if let val = response.value as? NSDictionary
                    {
                        print("VALLL--->",val)
                        
                    }
                    break
                case .failure(let error):
                    complete(false , error.localizedDescription)
                }
            }
    }
}
