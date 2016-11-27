//
//  Protocols.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/14/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import Foundation
import UIKit

// MARK: View

protocol ViewControllerProtocol {
    weak var responder: ViewResponderProtocol? { get set }
    weak var presenter: ViewControllerPresenterProtocol? { get set }
}

protocol ViewProtocol {
    weak var presenter: ViewPresenterProtocol? { get set }
}

protocol HeaderViewControllerProtocol: ViewControllerProtocol { }
protocol CollectionViewControllerProtocol: ViewControllerProtocol { }

protocol CellProtocol {
    static var cellIdentifier: String { get }
}

@objc protocol PresenterProtocol: class  {
    @objc func configure()
    @objc optional func layoutSubviews()
}

@objc protocol ViewControllerPresenterProtocol: PresenterProtocol {
    weak var viewController: UIViewController? { get set }
}

protocol ViewPresenterProtocol: PresenterProtocol {
    weak var view: UIView? { get set }
}

protocol ViewResponderProtocol: class {
    func didTouchedUpInside(_ sender: Any)
}

// MARK: Entity

@objc protocol ViewRepresentableProtocol {
    @objc func size(forObject: AnyObject) -> CGSize
}

@objc protocol PersistentEntityProtocol {
    @objc static func primaryKeyForRetrievedObjects() -> String
    @objc static func entityName() ->String
    @objc func update(objects: Dictionary<String, Any>,
                      localDate: Date)
}

@objc protocol PersistentEntityDataProtocol: PersistentEntityProtocol {
    @objc var shouldDownloadData: Bool { get set }
    @objc var dataRemoutePath: String { get }
    @objc var dataName: String? { get }
}

@objc protocol TemporaryEntityProtocol {
    @objc static func methodForRemouteUpdate() -> String
    @objc static func methodForlocalUpdate() -> String
    @objc static func requestURL(forMethod: String) -> String
    @objc func parameters(forMethod: String) -> Any?
    @objc func urlParameters(forMethod: String) -> [String : String]?
    @objc var offset: Int { get set }

}

@objc protocol EntityFetcherProtocol {
    @objc func save()
    @objc optional var entitiesCount: Int { get }
    @objc optional func getEntity(forIndex index: Int) -> PersistentEntityProtocol
    @objc optional func indexOf(_ entity: PersistentEntityProtocol) -> NSNumber?
    @objc func insert(_ entity: PersistentEntityProtocol, withName name: String) -> PersistentEntityProtocol
    @objc func remove(_ entity: PersistentEntityProtocol?, withName name: String?) 
    @objc func fetch(withName name: String) -> PersistentEntityProtocol
    @objc func fetchForUpdate(withKey key: String, name: String) -> PersistentEntityProtocol
    @objc func fetchForDelete(withDate date: Date, name: String) -> [PersistentEntityProtocol]?
    @objc func fetch(withPredicate predicate: NSPredicate?, name: String) -> [PersistentEntityProtocol]?
}

@objc protocol EntityWithDataFetcherProtocol: EntityFetcherProtocol {
    @objc func fetchWithoutData(name: String) -> [PersistentEntityDataProtocol]?
}

// MARK: Operation

@objc public protocol TrailingObjectProtocol: NSObjectProtocol {}

public protocol OperationWithObjectStorage {
    func setStorage(_ storage: TrailingObjectProtocol) -> Void
    func getStorage() -> TrailingObjectProtocol
}

// MARK: Network manager

typealias NetworkResponseSuccessBlock = (_ objects: [Dictionary<String, Any>]) -> (Void)
typealias NetworkResponseDataSuccessBlock = (_ objects: Data) -> (Void)
typealias NetworkResponseFailureBlock = (_ error: Error) -> (Void)

protocol NetworkManagerProtocol {
    func executeRequest(_ method: String,
                        requestURL: String,
                        parameters: Any?,
                        urlParameters: [String : String]?,
                        success: NetworkResponseSuccessBlock?,
                        failure: NetworkResponseFailureBlock?) -> URLSessionTask
}

protocol NetworkManagerDataProtocol: NetworkManagerProtocol {
    func download(from: String,
                  success: NetworkResponseDataSuccessBlock?,
                  failure: NetworkResponseFailureBlock?) -> URLSessionTask
}

// MARK: Model updater

protocol PersistantModelUpdaterManagerProtocol {
    func updatePersistent()
    var networkManager: NetworkManagerDataProtocol { get set }
    var persistentContext: EntityWithDataFetcherProtocol { get set }
    var persistentDataManager: DataManagerProtocol { get set }
}

protocol TemporaryModelUpdaterManagerProtocol {
    func updateTemporary()
    var networkManager: NetworkManagerDataProtocol { get set }
    var tempContext: EntityWithDataFetcherProtocol { get set }
    var tempDataManager: DataManagerProtocol { get set }
}

protocol PersistentDataModelUpdaterManagerProtocol: PersistantModelUpdaterManagerProtocol {
    
    associatedtype P: PersistentEntityDataProtocol
    associatedtype T: TemporaryEntityProtocol
    var persistentUpdater: DataModelUpdater<P, T> { get set }
}

protocol TemporaryDataModelUpdaterManagerProtocol: TemporaryModelUpdaterManagerProtocol {
    
    associatedtype P: PersistentEntityDataProtocol
    associatedtype T: TemporaryEntityProtocol
    var tempUpdater: DataModelUpdater<P, T> { get set }
}


@objc protocol ModelUpdaterProtocol { }

@objc protocol ModelUpdaterDelegate {
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                                willExecute task: URLSessionTask,
                                _ resume:(() -> Void))
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                                didGet response: [Dictionary<String, Any>]?,
                                error: Error?)
    // TODO: todo
//    @objc optional func updater(_ updater: ModelUpdaterProtocol,
//                                willUpdate entity: PersistentEntityProtocol,
//                                with objects: UnsafeMutablePointer<NSDictionary>)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                                didUpdate entity: PersistentEntityProtocol)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                                willDelete entity: PersistentEntityProtocol)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                                didFinishExecuting operation: ModelUpdaterOperation)
}

@objc protocol ModelUpdaterDataDelegate: ModelUpdaterDelegate {
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                 didDownload data: Data?,
                 forEntity: PersistentEntityDataProtocol,
                 error: Error?)
    // TODO: todo
//    @objc optional func updater(_ updater: ModelUpdaterProtocol,
//                 willWrite data: UnsafeMutablePointer<NSData>,
//                 forEntity: PersistentEntityDataProtocol)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                 didWrite data: Data,
                 forEntity: PersistentEntityDataProtocol,
                 error: Error?)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                 willDelete data: Data,
                 forEntity: PersistentEntityDataProtocol)
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                 queuePiority forEntity: PersistentEntityProtocol) -> Operation.QueuePriority
    @objc optional func updater(_ updater: ModelUpdaterProtocol,
                 qualityOfService: PersistentEntityProtocol) -> QualityOfService
}

protocol DataManagerProtocol {
    func write(data: Data, named: String, completed:((_ error: Error?) -> Void)?)
    func delete(data named: String, completed:((_ error: Error?) -> Void)?)
    func get(data named: String) -> Data?
}

