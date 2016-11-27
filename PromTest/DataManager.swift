//
//  DataManager.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/18/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import Foundation
import UIKit

class DataManager: NSObject, DataManagerProtocol {

    private var cachesPath: String { return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! }
    private var component: String { return "/CachedImages" }
    private var directory: URL { return URL(string: directory(forComponent: component))! }
    
    private func directory(forComponent: String) -> String {
        let directory = cachesPath.appending(forComponent)
        if !FileManager.default.fileExists(atPath: directory) {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory, isDirectory: true),
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("error while creating directory \(error)")
            }
        }
        return directory
    }
    
    func write(data: Data, named: String, completed:((_ error: Error?) -> Void)?) {
        write(data: data, name: named, filePath: directory.appendingPathComponent(named).absoluteString, completed: completed)
    }
    
    func delete(data named: String, completed:((_ error: Error?) -> Void)?) {
        let path = directory.appendingPathComponent(named).absoluteString
        do {
            try FileManager.default.removeItem(atPath: path)
            completed?(nil)
        } catch let error {
            completed?(error)
        }
    }
    
    func get(data named: String) -> Data? {
        return NSData(contentsOfFile: directory.appendingPathComponent(named).absoluteString) as Data?
    }
    
    func getImage(_ named: String) -> UIImage? {
        return UIImage(contentsOfFile: directory.appendingPathComponent(named).absoluteString)
    }
    
    func write(data: Data, name: String, filePath: String, completed:((_ error: Error?) -> Void)?) -> Void {
        if ( FileManager.default.fileExists(atPath: filePath) ) {
            do {
                try data.write(to: URL(fileURLWithPath: directory.absoluteString, isDirectory: false),
                               options: Data.WritingOptions.atomic)
                completed?(nil)
            } catch let error {
                completed?(error)
            }
        } else {
            FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
            completed?(nil)
        }
    }
}
