//
//  CollectionViewCell.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/20/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, CellProtocol, ViewProtocol {
    
    static var cellIdentifier: String { return "CollectionViewCellIdentifier" }

    let imageView = UIImageView(image: #imageLiteral(resourceName: "Spinner Frame 4-64"))
    let descriptionLabel = UILabel(frame: CGRect.zero)
    let priceLabel = UILabel()
    let discountLabel = UILabel()
    
    var presenter: ViewPresenterProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        addSubview(imageView)
        addSubview(descriptionLabel)
        addSubview(priceLabel)
        addSubview(discountLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        presenter?.configure()
    }
    
}
