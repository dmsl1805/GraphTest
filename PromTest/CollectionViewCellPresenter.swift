//
//  CollectionViewCellPresenter.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/20/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class CollectionViewCellPresenter: NSObject, ViewPresenterProtocol {
    
    let InteritemSpacing: CGFloat = 8.0
    weak var view: UIView?
    var availableWidth: CGFloat { return (UIScreen.main.bounds.size.width - InteritemSpacing*7) / 2.0 }
    var model: TemporaryEntity?

    func configure() {
        let cell = view as! CollectionViewCell
        
        var imageScaledSize = CGSize.zero
        if let size = cell.imageView.image?.size {
            imageScaledSize = CGSize(width: availableWidth, height: availableWidth / size.width * size.height)
        }
        cell.imageView.frame = CGRect(origin: CGPoint(x: InteritemSpacing, y: InteritemSpacing),
                                      size: imageScaledSize)
        
        let descrPoint = CGPoint(x: InteritemSpacing, y: cell.imageView.frame.origin.y + cell.imageView.frame.size.height + InteritemSpacing)
        let descrHeight = (cell.descriptionLabel.text?.heightWithConstrainedWidth(width: availableWidth,
                                                                                  font: cell.descriptionLabel.font)) ?? 0
        let descrSize = CGSize(width: availableWidth, height: descrHeight)
        cell.descriptionLabel.frame = CGRect(origin: descrPoint, size: descrSize)
        
        let pricePoint = CGPoint(x: InteritemSpacing, y: cell.descriptionLabel.frame.origin.y + cell.descriptionLabel.frame.size.height + InteritemSpacing)
        let priceSize = CGSize(width: availableWidth, height: 15)
        cell.priceLabel.frame = CGRect(origin: pricePoint, size: priceSize)
        
        let discountPoint = CGPoint(x: InteritemSpacing, y: cell.priceLabel.frame.origin.y + cell.priceLabel.frame.size.height + InteritemSpacing)
        let discountSize = CGSize(width: availableWidth, height: 10)
        cell.discountLabel.frame = CGRect(origin: discountPoint, size: discountSize)
        cell.descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        cell.descriptionLabel.numberOfLines = 35
        cell.priceLabel.font = UIFont.systemFont(ofSize: 16).bold()
        cell.discountLabel.font = UIFont.systemFont(ofSize: 14)
        cell.discountLabel.textColor = UIColor.lightGray
        cell.backgroundColor = UIColor.white
    }
    
    func update() {
        let cell = view as! CollectionViewCell

        cell.imageView.image = model?.image ?? #imageLiteral(resourceName: "Spinner Frame 4-64")
        cell.descriptionLabel.text = model?.dataName
        cell.descriptionLabel.isHidden = false
        cell.priceLabel.text = model?.priceText
        cell.discountLabel.text = model?.discountText
        
        let attributeString =  NSMutableAttributedString(string: model?.discountText ?? "")
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        
        cell.discountLabel.attributedText = attributeString
        cell.discountLabel.isHidden = model?.discountText == cell.priceLabel.text
    }
}
