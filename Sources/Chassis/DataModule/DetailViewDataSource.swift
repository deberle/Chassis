//
//  DetailViewDataSource.swift
//  Chassis
//
//  Created by Daniel Eberle on 18.09.20.
//

import Foundation
import CoreData

public enum ChangeType {
    case created
    case updated
    case deleted
}


open class DetailViewDataSource<T: NSManagedObject> {

    public typealias ChangeBlock = (T, ChangeType) -> Void

    let objectContext: NSManagedObjectContext
    let objectID: NSManagedObjectID
    let changeBlock: ChangeBlock

    public init(objectContext: NSManagedObjectContext, objectID: NSManagedObjectID,
         changeBlock: @escaping ChangeBlock) {

        self.objectContext = objectContext
        self.objectID = objectID
        self.changeBlock = changeBlock

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(objectsDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: self.objectContext)

        if let object: T = try? self.objectContext.existingObject(with: self.objectID) as? T {

            self.changeBlock(object, .created)
        }
    }

    @objc func objectsDidChange(_ notification: NSNotification) {

        if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
           , let object = updated.filter({ $0.objectID == self.objectID }).first as? T {

            self.changeBlock(object, .updated)
        } else if let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>
           , let object = deleted.filter({ $0.objectID == self.objectID }).first as? T {

            self.changeBlock(object, .deleted)
        } else if let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
           , let object = inserted.filter({ $0.objectID == self.objectID }).first as? T {

            self.changeBlock(object, .created)
        }
    }
}
