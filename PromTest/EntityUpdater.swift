
//  Created by Dmitriy Shulzhenko on 9/5/16.
//  Copyright © 2016 . All rights reserved.
//

import UIKit

@objc public enum ModelUpdaterOperation: Int {
    case downloadInfo
    case writeInfo
    case deleteInfo
    case deleteData
    case downloadDataAndWrite
}

class ModelUpdater<P, T>: NSObject, ModelUpdaterProtocol where P: PersistentEntityProtocol, T: TemporaryEntityProtocol {
    
    internal var queue: OperationQueue?
    
    internal let networkManager: NetworkManagerProtocol
    internal let context: EntityFetcherProtocol
    internal let method: String
    
    public var tempEntity: TemporaryEntityProtocol?
    public var delegate: ModelUpdaterDelegate?
    
    init(context: EntityFetcherProtocol,
         networkManager: NetworkManagerProtocol,
         method: String,
         tempEntity: TemporaryEntityProtocol?,
         delegate: ModelUpdaterDelegate? = nil,
         queue: OperationQueue? = OperationQueue()) {
        self.queue = queue
        self.networkManager = networkManager
        self.tempEntity = tempEntity
        self.method = method
        self.context = context
        self.delegate = delegate
        super.init()
    }
    
    convenience init(updateLocal context: EntityFetcherProtocol,
                     networkManager: NetworkManagerProtocol,
                     tempEntity: TemporaryEntityProtocol?,
                     delegate: ModelUpdaterDelegate? = nil) {
        self.init(context: context,
                  networkManager: networkManager,
                  method: TemporaryEntity.methodForlocalUpdate(),
                  tempEntity: tempEntity,
                  delegate: delegate)
    }
    
    convenience init(updateRemoute context: EntityFetcherProtocol,
                     networkManager: NetworkManagerProtocol,
                     tempEntity: TemporaryEntityProtocol?,
                     delegate: ModelUpdaterDelegate? = nil) {
        self.init(context: context,
                  networkManager: networkManager,
                  method: TemporaryEntity.methodForRemouteUpdate(),
                  tempEntity: tempEntity,
                  delegate: delegate)
    }
    
    internal var downloadInfo: AsyncOperation {
        return AsyncOperation { [unowned self] operation in
            let mngr = self.networkManager
            let task = mngr.executeRequest(self.method,
                                           requestURL: TemporaryEntity.requestURL(forMethod: self.method),
                                           parameters: self.tempEntity?.parameters(forMethod: self.method),
                                           urlParameters: self.tempEntity?.urlParameters(forMethod: self.method),
                                           success: { [unowned self] in
                                            (operation.getStorage() as! ResponseStorage).response = .success(objects: $0)
                                            self.delegate?.updater?(self, didGet: $0, error: nil)
                                            operation.finish()
                                            self.delegate?.updater?(self, didFinishExecuting: .downloadInfo)},
                                           failure: { [unowned self] in
                                            (operation.getStorage() as! ResponseStorage).response = .failure(error: $0)
                                            self.delegate?.updater?(self, didGet: nil, error: $0)
                                            operation.finish()
                                            self.delegate?.updater?(self, didFinishExecuting: .downloadInfo)})
            self.delegate?.updater?(self, willExecute: task, {
                if case .suspended = task.state {
                    task.resume()
                }
            }) ?? task.resume()
        }
    }
    
    internal var writeInfo: AsyncOperation {
        return AsyncOperation { [unowned self] (operation) in
            if let response = (operation.getStorage() as! ResponseStorage).response, case .success(let objects) = response {
                for var properties in objects {
                    let key = "\(properties[P.primaryKeyForRetrievedObjects()] as! NSNumber)"
                    let entity = self.context.fetchForUpdate(withKey: key, name: P.entityName())
//                    self.delegate?.updater?(self, willUpdate: entity, with: properties as NSDictionary)
                    entity.update(objects: properties,
                                  localDate: (operation.getStorage() as! ResponseStorage).date)
                    self.delegate?.updater?(self, didUpdate: entity)
                }
                self.context.save()
                operation.finish()
                self.delegate?.updater?(self, didFinishExecuting: .writeInfo)
            } else {
                self.context.save()
                operation.finish()
                self.delegate?.updater?(self, didFinishExecuting: .writeInfo)
            }
        }
    }
    
    internal var deleteInfo: AsyncOperation {
        return AsyncOperation { [unowned self] (operation) in
            if let response = (operation.getStorage() as! ResponseStorage).response, case .success(_) = response {
                if let objectsToDelete = self.context.fetchForDelete(withDate: (operation.getStorage() as! ResponseStorage).date, name: P.entityName()) {
                    for objectToDelete in objectsToDelete {
                        self.delegate?.updater?(self, willDelete: objectToDelete)
                        self.context.remove(objectToDelete, withName: P.entityName())
                    }
                }
                self.context.save()
                operation.finish()
                self.delegate?.updater?(self, didFinishExecuting: .deleteInfo)
            } else {
                self.context.save()
                operation.finish()
                self.delegate?.updater?(self, didFinishExecuting: .deleteInfo)
            }
        }
    }
    
    internal func operation(from: ModelUpdaterOperation) -> AsyncOperation? {
        switch from {
        case .downloadInfo: return downloadInfo
        case .writeInfo: return writeInfo
        case .deleteInfo: return deleteInfo
        default: return nil
        }
    }
    
    internal func execute(_ operations: [ModelUpdaterOperation], storage: TrailingObjectProtocol) {
        
        guard queue?.operations.count == 0 else { return }
        
        var newOps = operations.map { (modelUpdaterOperation) -> AsyncOperation in return operation(from: modelUpdaterOperation)! }
        for (index, operation) in newOps.enumerated() {
            if index == 0 {
                operation.setStorage(storage)
            } else {
                operation.addDependency(newOps[index - 1])
            }
        }
        queue?.addOperations(newOps, waitUntilFinished: false)
    }
    
    func execute() {
        return execute([.downloadInfo, .writeInfo, .deleteInfo])
    }
    
    func execute(_ operations: [ModelUpdaterOperation]) {
        execute(operations, storage: ResponseStorage())
    }
}

class DataModelUpdater<P, T>: ModelUpdater<P, T> where P: PersistentEntityDataProtocol, T: TemporaryEntityProtocol {
    internal let dataQueue: OperationQueue
    var dataManager: DataManagerProtocol
    
    init(context: EntityWithDataFetcherProtocol,
         networkManager: NetworkManagerDataProtocol,
         dataManager: DataManagerProtocol,
         method: String,
         tempEntity: TemporaryEntity?,
         delegate: ModelUpdaterDataDelegate? = nil,
         infoQueue: OperationQueue = OperationQueue(),
         dataQueue: OperationQueue = OperationQueue()) {
        self.dataQueue = dataQueue
        self.dataManager = dataManager
        super.init(context: context,
                   networkManager: networkManager,
                   method: method,
                   tempEntity: tempEntity,
                   delegate: delegate,
                   queue: infoQueue)
    }
    
    convenience init(updateLocalWithData context: EntityWithDataFetcherProtocol,
                     networkManager: NetworkManagerDataProtocol,
                     dataManager: DataManagerProtocol,
                     tempEntity: TemporaryEntity?,
                     delegate: ModelUpdaterDataDelegate? = nil,
                     infoQueue: OperationQueue = OperationQueue(),
                     dataQueue: OperationQueue = OperationQueue()) {
        self.init(context: context,
                  networkManager: networkManager,
                  dataManager: dataManager,
                  method: T.methodForlocalUpdate(),
                  tempEntity: tempEntity,
                  delegate: delegate,
                  infoQueue: infoQueue,
                  dataQueue: dataQueue)
    }
    
    private var downloadDataAndWrite: [AsyncOperation] {
        let manager = self.networkManager as! NetworkManagerDataProtocol
        let delegate = self.delegate as? ModelUpdaterDataDelegate
        let context = self.context as! EntityWithDataFetcherProtocol
        var downloadDataAndWrite = [AsyncOperation]()
        if let entities = context.fetchWithoutData(name: P.entityName()) {
            for entity in entities {
                let downloadAndWrite = AsyncOperation { operation in
                    guard URL(string: entity.dataRemoutePath) != nil else {
                        operation.finish()
                        self.delegate?.updater?(self, didFinishExecuting: .downloadDataAndWrite)
                        return
                    }
                    let _ = manager.download(from: entity.dataRemoutePath,
                                             success: { (data) -> (Void) in
                                                delegate?.updater?(self, didDownload: data, forEntity:entity, error: nil)
                                                let dataToWrite = data
//                                                delegate?.updater?(self, willWrite: dataToWrite as NSData, forEntity:entity)
                                                self.dataManager.write(data: dataToWrite, named: entity.dataName!, completed: { error in
                                                    entity.shouldDownloadData = error != nil
                                                    delegate?.updater?(self, didWrite: dataToWrite, forEntity:entity, error: error)
                                                    context.save()
                                                    operation.finish()
                                                    self.delegate?.updater?(self, didFinishExecuting: .downloadDataAndWrite)
                                                })},
                                             failure: { (error) -> (Void) in
                                                delegate?.updater?(self, didDownload: nil, forEntity:entity, error: error)
                                                operation.finish()
                                                self.delegate?.updater?(self, didFinishExecuting: .downloadDataAndWrite)
                    })
                }
                if let delegate = delegate {
                    downloadAndWrite.queuePriority = delegate.updater?(self, queuePiority: entity) ?? .normal
                    downloadAndWrite.qualityOfService = delegate.updater?(self, qualityOfService: entity) ?? .utility
                }
                downloadDataAndWrite.append(downloadAndWrite)
            }
        }
        return downloadDataAndWrite
    }
    
    internal var deleteData: AsyncOperation {
        return AsyncOperation { [unowned self] (operation) in
            let context = self.context as! EntityWithDataFetcherProtocol
            let date = (operation.getStorage() as! ResponseStorage).date
            if let objects = context.fetchForDelete(withDate: date, name: P.entityName()) as? [PersistentEntityDataProtocol] {
                for entity in objects {
                    self.dataManager.delete(data: entity.dataName!, completed: nil)
                }
            }
            operation.finish()
            self.delegate?.updater?(self, didFinishExecuting: .deleteData)
        }
    }
    
    override func execute() {
        execute([.downloadInfo, .writeInfo, .deleteData, .deleteInfo])
    }
    
    override func operation(from: ModelUpdaterOperation) -> AsyncOperation? {
        var op = super.operation(from: from)
        if op == nil {
            switch from {
            case .deleteData: op = deleteData
            default: break
            }
        }
        return op
    }
    
    override func execute(_ operations: [ModelUpdaterOperation]) {
        var ops = operations
        if ops.contains(.downloadDataAndWrite) {
            ops.remove(at: ops.index(of: .downloadDataAndWrite)!)
        }
        
        execute(ops, storage: DataResponseStorage())

        guard dataQueue.operations.count == 0 && operations.contains(.downloadDataAndWrite) else { return }

        queue?.operations.last?.completionBlock = { [unowned self] () in
            self.dataQueue.addOperations(self.downloadDataAndWrite, waitUntilFinished: false)
        }
    }
    
}
