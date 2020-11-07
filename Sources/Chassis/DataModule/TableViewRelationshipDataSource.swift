//
//  TableViewRelationshipDataSource.swift
//  PTC_Traditional
//
//  Created by Daniel Eberle on 21.09.20.
//

import Foundation
import UIKit
import CoreData

class TableViewRelationshipDataSource<T: NSManagedObject>: UITableViewDiffableDataSource<String, NSManagedObjectID> {

    var setupInProgress = true
    let objectContext: NSManagedObjectContext
    let parentObjectID: NSManagedObjectID
    let relationshipName: String
    var fetchedObjects: NSMutableOrderedSet?

    var parentObject: NSManagedObject? {

        guard let parentObject = try? self.objectContext.existingObject(with: self.parentObjectID) else { return nil }
        return parentObject
    }
    var relationship: NSRelationshipDescription? {

        return self.parentObject?
            .entity.relationshipsByName[self.relationshipName]
    }
    var inverseRelationship: NSRelationshipDescription? {

        return self.relationship?.inverseRelationship
    }
    var inverseRelationshipName: String? {

        return self.inverseRelationship?.name
    }
    var isToMany: Bool? {

        return self.relationship?.isToMany
    }
    var inverseIsToMany: Bool? {

        return self.inverseRelationship?.isToMany
    }
    
    init(tableView: UITableView,
         objectContext: NSManagedObjectContext,
         parentObjectID: NSManagedObjectID,
         relationshipName: String,
         cellProvider: @escaping UITableViewDiffableDataSource<String, NSManagedObjectID>.CellProvider) {
        
        self.objectContext = objectContext
        self.parentObjectID = parentObjectID
        self.relationshipName = relationshipName
        super.init(tableView: tableView, cellProvider: cellProvider)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(objectsDidChange(_:)),
                         name: .NSManagedObjectContextObjectsDidChange,
                         object: self.objectContext)

    }
    
    

    func performInitialFetch() {
        
        guard let parentObject = self.parentObject else { return }
        self.fetchedObjects = parentObject.mutableOrderedSetValue(forKey: self.relationshipName)
    }
    
    @objc func objectsDidChange(_ notification: NSNotification) {

        guard let inverseRelationshipName = self.inverseRelationshipName
              , let inverseIsToMany = self.inverseIsToMany else { return }

        if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
           , let _ = updated.filter( { object in
            if inverseIsToMany {

                if let inverseRelationships = object.value(forKey: inverseRelationshipName) as? NSSet {
                    inverseRelationships.contains(self.parentObjectID)
                }
            }
            else {

            }
            return true
           }) as? Set<T> {
            
            
        }
//        else if let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>
//                  , let object = deleted.filter({ $0.objectID == self.objectID }).first as? T {
//
//        }
//        else if let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
//                  , let object = inserted.filter({ $0.objectID == self.objectID }).first as? T {
//
//        }
        
    }
}
