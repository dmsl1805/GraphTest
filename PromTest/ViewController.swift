//
//  ViewController.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/14/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    var headerViewController: SortHeaderViewController?
    var collectionViewPresenter = CollectionViewPresenter()
    var headerViewPresenter = HeaderViewPresenter()
    
    let persistentContext = PersistentContextStorage(modelName: "PRMModel")
    let persistentDataManager = DataManager()
    let networkManager = NetworkManager()
    let tempContext = TemporaryContextStorage()
    let tempDataManager = TempDataManager()
    
    override func viewDidLoad() {
        self.title = "Платья женские"
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionViewController = segue.destination as? CollectionViewController {
            collectionViewPresenter.viewController = collectionViewController
            collectionViewController.presenter = collectionViewPresenter
            collectionViewPresenter.updatesManagerTemporary = TemporaryModelUpdaterManager<TemporaryEntity, TemporaryEntity>(networkManager: networkManager,
                                                                                                                             tempContext: tempContext,
                                                                                                                             tempDataManager: tempDataManager,
                                                                                                                             delegate: collectionViewPresenter)
            collectionViewPresenter.updatesManagerPersistent = PersistentModelUpdaterManager<PRMEntity, TemporaryEntity>(networkManager: networkManager,
                                                                                                                               persistentContext: persistentContext,
                                                                                                                               persistentDataManager: persistentDataManager,
                                                                                                                               delegate: collectionViewPresenter)
            collectionViewPresenter.headerView = headerViewPresenter
        } else if let headerViewController = segue.destination as? SortHeaderViewController {
            headerViewPresenter.viewController = headerViewController
            headerViewController.presenter = headerViewPresenter
            headerViewController.responder = collectionViewPresenter
        }
    }
}

