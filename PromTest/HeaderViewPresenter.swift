//
//  HeaderViewPresenter.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/23/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class HeaderViewPresenter: NSObject, ViewControllerPresenterProtocol {
    weak var viewController: UIViewController?
    
    var sortType : PossibleSorts? { didSet { (viewController as! SortHeaderViewController).sortByButton.setTitle(sortType?.rawValue.localized, for: .normal) } }
    
    func configure() {
        let header = viewController as! SortHeaderViewController
        header.sortLabel.text = "Sort by".localized
        sortType = .popularity
    }
}
