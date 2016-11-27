//
//  TempDataManager.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/21/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class TempDataManager: NSObject, DataManagerProtocol {
    
    let cashe = NSCache<NSString, UIImage>()
    
    func write(data: Data, named: String, completed:((_ error: Error?) -> Void)?) {
        if let image = UIImage(data: data) {
        cashe.setObject(image, forKey: named as NSString)
        completed?(nil)
        } else {
            completed?(nil)
        }
    }
    
    func delete(data named: String, completed:((_ error: Error?) -> Void)?) {
        cashe.removeObject(forKey: named as NSString)
        completed?(nil)
    }
    
    func get(data named: String) -> Data? {
        if let image = cashe.object(forKey: named as NSString) {
         return UIImagePNGRepresentation(image)
        } else {
            return nil
        }
    }
}
