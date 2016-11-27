// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PRMEntity.swift instead.

import Foundation
import CoreData

public enum PRMEntityAttributes: String {
    case discounted_price = "discounted_price"
    case hasImage = "hasImage"
    case id = "id"
    case name = "name"
    case price = "price"
    case price_currency = "price_currency"
    case url_main_image_200_200 = "url_main_image_200_200"
}

open class _PRMEntity: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "PRMEntity"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _PRMEntity.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var discounted_price: NSNumber?

    @NSManaged open
    var hasImage: NSNumber?

    @NSManaged open
    var id: NSNumber?

    @NSManaged open
    var name: String?

    @NSManaged open
    var price: NSNumber?

    @NSManaged open
    var price_currency: String?

    @NSManaged open
    var url_main_image_200_200: String?

    // MARK: - Relationships

}

