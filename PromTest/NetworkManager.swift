//
//  NetworkManager.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/16/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit
import Alamofire

class ParameterEncoder: NSObject, ParameterEncoding {
    var value: String
    init(_ value: String) {
        self.value = value
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = self.value.data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

class NetworkManager: NSObject, NetworkManagerDataProtocol {
    func executeRequest(_ method: String,
                        requestURL: String,
                        parameters: Any?,
                        urlParameters: [String : String]?,
                        success: NetworkResponseSuccessBlock?,
                        failure: NetworkResponseFailureBlock?) -> URLSessionTask {
        var newUrl: String = requestURL
        if let params = urlParameters, params.count > 0 {
            var urlForAppend = "?"
            for (key, value) in params {
                urlForAppend = urlForAppend.appending("\(key)=\(value)&")
            }
            newUrl = newUrl.appending(urlForAppend)
        }
        
        
        return Alamofire.request(newUrl,
                                 method: HTTPMethod(rawValue: method)!,
                                 encoding: ParameterEncoder((parameters as! String))).responseJSON(queue: DispatchQueue.global(qos: .utility)){ dataResponse in
                                    switch dataResponse.result {
                                    case .failure(let error): failure?(error)
                                    case .success(let value):
                                        let catalog = (value as! Dictionary<String, Any>)["catalog"] as! Dictionary<String, Any>
                                        let results = catalog["results"] as! [Dictionary<String, Any>]
                                        success?(results)
                                    }
            }.task!
    }
    
    func download(from: String,
                  success: NetworkResponseDataSuccessBlock?,
                  failure: NetworkResponseFailureBlock?) -> URLSessionTask {
        return Alamofire.request(URL(string: from)!).responseData(queue: DispatchQueue.global(qos: .utility)) { response in
            switch response.result {
            case .failure(let error): failure?(error)
            case .success(let value): success?(value)
            }
            
            }.task!
    }
}
