//
//  PRMSortHeaderViewController.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/14/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class SortHeaderViewController: UIViewController, HeaderViewControllerProtocol {

    var responder: ViewResponderProtocol?
    var presenter: ViewControllerPresenterProtocol?
    
    @IBOutlet var sortLabel: UILabel!
    @IBOutlet var sortByButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        presenter?.configure()
    }
    
    @IBAction func sortByPressed(_ sender: UIButton) {
        responder?.didTouchedUpInside(sender)
    }
}
