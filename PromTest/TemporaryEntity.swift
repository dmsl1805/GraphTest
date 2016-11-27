//
//  DressViewModel.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/20/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

enum PriceCurrency: Int {
    case UAH = 1
    func description() -> String {
        switch self {
        case .UAH: return "UAH".localized
        }
    }
    init?(string: String!) {
        switch string {
        case "UAH": self = .UAH
        default:  return nil
        }
    }
}

class TemporaryEntity: NSObject, TemporaryEntityProtocol, PersistentEntityDataProtocol, ViewRepresentableProtocol {
    
    @objc internal static func entityName() -> String { return "TemporaryEntity" }
    
    private let limit: Int
    private let category: Int
    private var collectionViewLayoutSize = CGSize.zero
    
    var sort: PossibleSorts
    var offset = 0
    
    // MARK: PersistentEntityDataProtocol
    
    private var hasData: Bool = false
    @objc var shouldDownloadData: Bool { get { return image == nil } set { } }
    @objc var dataRemoutePath: String = ""
    @objc var dataName: String? { didSet { if oldValue != dataName { recountCollectionViewLayoutSizeSize() } } }
    
    var image: UIImage? { didSet { if oldValue != image { recountCollectionViewLayoutSizeSize() } } }
    var priceText: String?
    var discountText: String?
    var currency: PriceCurrency?
    var id: NSNumber?
    
    init (entity: PRMEntity?, template: (limit: Int?, category: Int?, sort: PossibleSorts?)? ) {
        dataName = entity?.name ?? ""
        if let currency = entity?.price_currency {
            self.currency = PriceCurrency(string: currency)
        }
        
        if let discount = entity?.discounted_price?.intValue, let price = entity?.price?.intValue {
            if discount < price {
                priceText = "\(discount) \(currency?.description() ?? "")"
                discountText = "\(price) \(currency?.description() ?? "")"
            } else {
                priceText = "\(price) \(currency?.description() ?? "")"
                discountText = "\(discount) \(currency?.description() ?? "")"
            }
        } else {
            priceText = "\(entity?.price?.intValue ?? 0) \(currency?.description() ?? "")"
            discountText = "\(entity?.discounted_price?.intValue ?? 0) \(currency?.description() ?? "")"
        }
        
        limit = template?.limit ?? 10
        category = template?.category ?? 35402
        sort = template?.sort ?? .popularity
    }
    
    convenience init (template: (limit: Int?, category: Int?, sort: PossibleSorts?)?) {
        self.init(entity: nil, template: template )
    }
    
    // MARK: TemporaryEntityProtocol
    
    static func methodForRemouteUpdate() -> String { return "POST" }
    
    static func methodForlocalUpdate() -> String { return "POST" }
    
    static func requestURL(forMethod: String) -> String { return PROM_DOMAIN + PROM_GPAPH_REQUEST }
    
    func parameters(forMethod: String) -> Any? {
        return "[{:catalog [:possible_sorts {:results [:id :name :price_currency :discounted_price :price :url_main_image_200x200 ]}]}]"
    }
    
    func urlParameters(forMethod: String) -> [String : String]? {
        return ["limit" : "\(limit)",
            "offset" : "\(offset)",
            "category" : "\(category)",
            "sort" : sort.rawValue]
    }
    
    // MARK: PersistentEntityProtocol
    
    static func primaryKeyForRetrievedObjects() -> String { return "id" }
    
    func update(objects: Dictionary<String, Any>,
                localDate: Date) {
        if let currency = objects["price_currency"] as? String {
            self.currency = PriceCurrency(string: currency)
        }
        dataRemoutePath = objects["url_main_image_200x200"] as? String ?? ""
        dataName = objects["name"] as? String ?? ""
        discountText = "\(objects["discounted_price"] as? String ?? "") \(currency?.description() ?? "")"
        priceText = "\(objects["price"] as? String ?? "") \(currency?.description() ?? "")"
        id = objects["id"] as? NSNumber
    }
    
    @objc func size(forObject: AnyObject) -> CGSize {
        if forObject.isKind(of: UICollectionViewLayout.self) {
            return collectionViewLayoutSize
        } else {
            return CGSize.zero
        }
    }
    
    private func recountCollectionViewLayoutSizeSize() {
        let InteritemSpacing: CGFloat = 8.0
        
        var availableWidth: CGFloat { return (UIScreen.main.bounds.size.width - InteritemSpacing*7) / 2.0 }
        
        let methodStart = NSDate()
        
        var imageScaledSize = CGSize(width: availableWidth, height: availableWidth)
        if let size = image?.size {
            imageScaledSize = CGSize(width: availableWidth, height: availableWidth / size.width * size.height)
        }
        let imageHeight = InteritemSpacing + imageScaledSize.height
        let descrHeight = InteritemSpacing + (dataName?.heightWithConstrainedWidth(width: availableWidth,
                                                                                   font: UIFont.systemFont(ofSize: 14)) ?? 0)
        
        
        let methodFinish = NSDate()
        let executionTime = methodFinish.timeIntervalSince(methodStart as Date)
        print("Execution time: \(executionTime)")
        collectionViewLayoutSize = CGSize(width: availableWidth, height: imageHeight + descrHeight + 25)
    }
}
