//
//  ProgressCollectionReusableView.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/24/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProgressCollectionReusableView: UICollectionReusableView {
    var hud: MBProgressHUD?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hud = MBProgressHUD.showAdded(to: self, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
