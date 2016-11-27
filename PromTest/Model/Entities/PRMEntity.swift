import Foundation
import CoreData

@objc(PRMEntity)
open class PRMEntity: _PRMEntity, PersistentEntityDataProtocol {
    
    // MARK: EntityProtocol

    @objc static func primaryKeyForRetrievedObjects() -> String { return PRMEntityAttributes.id.rawValue }

    @objc func update(objects: Dictionary<String, Any>, localDate: Date) {
        price_currency = objects["price_currency"] as? String
        url_main_image_200_200 = objects["url_main_image_200x200"] as? String
        name = objects["name"] as? String
        discounted_price = NSNumber(value: Float("\(objects["discounted_price"] ?? 0)")!)
        price = NSNumber(value: Float("\(objects["price"] ?? 0)")!)
        id = objects["id"] as? NSNumber
        hasImage = NSNumber(value: false)
    }

    var shouldDownloadData: Bool {
        get { return hasImage?.boolValue ?? false }
        set { hasImage = NSNumber(value: newValue) }
    }
    var dataRemoutePath: String { get { return url_main_image_200_200 ?? "" } }
    var dataName: String? { get { return name ?? "" } }
}
