//
//  ModelUpdaterManager.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/23/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class PersistentModelUpdaterManager<P, T>: NSObject, PersistentDataModelUpdaterManagerProtocol where P: PersistentEntityDataProtocol, T: TemporaryEntityProtocol {
    var networkManager: NetworkManagerDataProtocol
    var persistentContext: EntityWithDataFetcherProtocol
    var persistentDataManager: DataManagerProtocol
    var persistentUpdater: DataModelUpdater<P, T>
    var delegate: ModelUpdaterDataDelegate?

    init( networkManager: NetworkManagerDataProtocol,
          persistentContext: EntityWithDataFetcherProtocol,
          persistentDataManager: DataManagerProtocol,
          delegate: ModelUpdaterDataDelegate? = nil){
        self.networkManager = networkManager
        self.persistentContext = persistentContext
        self.persistentDataManager = persistentDataManager
        persistentUpdater = DataModelUpdater<P, T>(updateLocalWithData: persistentContext,
                                                   networkManager: networkManager,
                                                   dataManager: persistentDataManager,
                                                   tempEntity: TemporaryEntity(template: nil),
                                                   delegate: delegate)
    }
    
    func updatePersistent() {
        //TODO: add delete data operation
        persistentUpdater.execute([.downloadInfo, .writeInfo, .downloadDataAndWrite])
    }
}

class TemporaryModelUpdaterManager<P, T>: NSObject, TemporaryDataModelUpdaterManagerProtocol, ModelUpdaterDataDelegate where P: PersistentEntityDataProtocol, T: TemporaryEntityProtocol {

    var networkManager: NetworkManagerDataProtocol
    var tempContext: EntityWithDataFetcherProtocol
    var tempDataManager: DataManagerProtocol
    var tempUpdater: DataModelUpdater<P, T>
    var delegate: ModelUpdaterDataDelegate?
    
    init(networkManager: NetworkManagerDataProtocol,
        tempContext: EntityWithDataFetcherProtocol,
        tempDataManager: DataManagerProtocol,
        delegate: ModelUpdaterDataDelegate? = nil){
        self.networkManager = networkManager
        self.tempContext = tempContext
        self.tempDataManager = tempDataManager
        tempUpdater = DataModelUpdater<P, T>(updateLocalWithData: tempContext,
                                             networkManager: networkManager,
                                             dataManager: tempDataManager,
                                             tempEntity: TemporaryEntity(template: nil),
                                             delegate: delegate)
    }
    
    func updateTemporary() {
        tempUpdater.tempEntity?.offset = tempContext.entitiesCount ?? 0
        tempUpdater.execute([.downloadInfo, .writeInfo, .downloadDataAndWrite])
    }
    
    func updateTemporary(sort: PossibleSorts) {
        if sort != (tempUpdater.tempEntity as? TemporaryEntity)?.sort {
            tempUpdater.tempEntity?.offset = 0
            (tempUpdater.tempEntity as? TemporaryEntity)?.sort = sort
            tempUpdater.execute([.downloadInfo, .deleteInfo, .deleteData, .writeInfo, .downloadDataAndWrite])
        } else {
            (tempUpdater.tempEntity as? TemporaryEntity)?.sort = sort
            self.updateTemporary()
        }
    }
}


