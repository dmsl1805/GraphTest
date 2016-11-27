//
//  ContextStorage.swift
//
//  Created by Dmitriy Shulzhenko on 9/10/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import CoreData

class PersistentContextStorage: NSObject, EntityWithDataFetcherProtocol {
    let modelName: String
    let persistentStoreCoordinator: NSPersistentStoreCoordinator

    
    var background: NSManagedObjectContext
    var main: NSManagedObjectContext
    
    init(modelName name: String) {
        self.modelName = name
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        let modelURL = Bundle.main.url(forResource: name, withExtension: "momd")!
        let objectModel = NSManagedObjectModel(contentsOf: modelURL)!
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        var directory: ObjCBool = ObjCBool(false)
        if ( !FileManager.default.fileExists(atPath: docDir.path, isDirectory: &directory) ) {
            do {
                try FileManager.default.createDirectory(atPath: docDir.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError  {
                print("Could not create directory for persistent store\(error), \(error.userInfo)")
            }
        }
        let storeURL = docDir.appendingPathComponent("xModel")
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: storeURL,
                                                              options: options)
        } catch let error as NSError  {
            print("Could not create persistent store\(error), \(error.userInfo)")
        }
        
        main = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        main.persistentStoreCoordinator = persistentStoreCoordinator
        background = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        background.persistentStoreCoordinator = persistentStoreCoordinator
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeFromNotification(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: background)
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func mergeFromNotification(notification: Notification) -> Void {
        guard notification.object as! NSManagedObjectContext === background else {
            return
        }
        main.mergeChanges(fromContextDidSave: notification)
    }
    
    @objc func save() {
        guard background.hasChanges else {
            return
        }
        
        do {
            try background.save()
        } catch let error as NSError  {
            print("Could not save background context\(error), \(error.userInfo)")
        }
    }
    
    @objc func insert(_ entity: PersistentEntityProtocol, withName name: String) -> PersistentEntityProtocol {
        return NSEntityDescription.insertNewObject(forEntityName: name,
                                                   into: background) as! PersistentEntityProtocol
    }
    
    @objc func remove(_ entity: PersistentEntityProtocol?, withName name: String?) {
        let object = entity as! NSManagedObject
        object.managedObjectContext?.delete(object)
    }
    
    @objc func fetch(withName name: String) -> PersistentEntityProtocol {
        return self.fetch(withPredicate: nil, name: name)?.first ??
            NSEntityDescription.insertNewObject(forEntityName: name,
                                                into: background) as! PersistentEntityProtocol
    }
    
    @objc func fetchForUpdate(withKey key: String, name: String) -> PersistentEntityProtocol {
        return fetch(withPredicate: NSPredicate(format: "%K == %@", PRMEntityAttributes.id.rawValue, key), name: name)?.first ?? NSEntityDescription.insertNewObject(forEntityName: name, into: background) as! PersistentEntityProtocol
    }
    
    @objc func fetchForDelete(withDate date: Date, name: String) -> [PersistentEntityProtocol]? {
        return nil//self.fetch(withPredicate: nil, name: name)
    }
    
    @objc func fetch(withPredicate predicate: NSPredicate?, name: String) -> [PersistentEntityProtocol]? {
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: name, in: main)
        request.predicate = predicate
        do {
            let results = try main.fetch(request)
            return (results as! [PersistentEntityProtocol])
        } catch let error {
            print("error while fetching with predicate \(predicate), from persistent store, error: \(error)")
            return nil
        }
    }
    
    @objc func fetchWithoutData(name: String) -> [PersistentEntityDataProtocol]? {
        return fetch(withPredicate: NSPredicate(format: "%K == %@",
                                                PRMEntityAttributes.hasImage.rawValue,
                                                NSNumber(value: false)),
                     name: name) as? [PersistentEntityDataProtocol]
    }
}
