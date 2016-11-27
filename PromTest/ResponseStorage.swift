//
//  ResponceStorage.swift
//
//  Created by Dmitriy Shulzhenko on 11/10/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum NetworkResponse {
    case success(objects: [Dictionary<String, Any>])
    case failure(error: Error)
}

class ResponseStorage: NSObject, TrailingObjectProtocol{
    var response: NetworkResponse?
    var date = Date()
    
}

class DataResponseStorage: ResponseStorage{
    var data: Data?
}
