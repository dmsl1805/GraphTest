//
//  TemporaryContextStorage.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/21/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

//struct CacheKey: Hashable {
//    let index: Int
//    let key: String
//    
//    var hashValue: Int { get { return index } }
//    public static func ==(lhs: CacheKey, rhs: CacheKey
//        ) -> Bool { return lhs.index == rhs.index }
//
//}

class TemporaryContextStorage: NSObject, EntityWithDataFetcherProtocol {
    
    private var entities = [TemporaryEntity]()
    
    @objc var entitiesCount: Int { return entities.count }
    
    @objc func getEntity(forIndex index: Int) -> PersistentEntityProtocol { return entities[index] }
    
    @objc func save() {}
    
    @objc func insert(_ entity: PersistentEntityProtocol, withName name: String) -> PersistentEntityProtocol {
        let object = entity as! TemporaryEntity
        object.offset = entities.count
        entities.append(object)
        return object
    }
    
    @objc func remove(_ entity: PersistentEntityProtocol?, withName name: String?)  {
        let index = entities.index(of: entity as! TemporaryEntity)
        entities.remove(at: index!)
    }
    
    @objc func fetch(withName name: String) -> PersistentEntityProtocol {
        for entity in entities {
            if entity.dataName == name {
                return entity
            }
        }
        let entity = TemporaryEntity(template: nil)
        entity.dataName = name
        return entity
    }
    
    @objc func fetchForUpdate(withKey key: String, name: String) -> PersistentEntityProtocol {
        for entity in entities {
            if entity.dataName == name {
                return entity
            }
        }
        let entity = TemporaryEntity(template: nil)
        entity.dataName = name
        entity.id = NSNumber(value: Int(key)!)
        entities.append(entity)
        return entity
    }
    
    @objc func fetchForDelete(withDate date: Date, name: String) -> [PersistentEntityProtocol]? {
        return entities
    }
    
    @objc func fetch(withPredicate predicate: NSPredicate?, name: String) -> [PersistentEntityProtocol]? {
        return entities
    }
    
    @objc func fetchWithoutData(name: String) -> [PersistentEntityDataProtocol]? {
        var withoutData = [PersistentEntityDataProtocol]()
        for entity in entities {
            if entity.image == nil {
                withoutData.append(entity)
            }
        }
        return withoutData
    }
    func indexOf(_ entity: PersistentEntityProtocol) -> NSNumber? {
        if let index = entities.index(of: entity as! TemporaryEntity) {
            return NSNumber(value: index)
        } else {
            return nil
        }
    }
    
}
