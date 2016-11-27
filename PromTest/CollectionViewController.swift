//
//  CollectionViewController.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/20/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, CollectionViewControllerProtocol {

    weak var responder: ViewResponderProtocol?
    weak var presenter: ViewControllerPresenterProtocol?
    
    var refresh: ((_ finished: @escaping (() -> Void)) -> Void)?
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.configure()

        if ( refresh != nil ) {
            refreshControl.addTarget(self, action: #selector(CollectionViewController.startRefresh), for: .valueChanged)
            collectionView?.addSubview(refreshControl)
        }
    }
    
    @objc func startRefresh() {
        self.refresh! { [unowned self] in self.refreshControl.endRefreshing() }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        presenter?.layoutSubviews?()
    }
}
