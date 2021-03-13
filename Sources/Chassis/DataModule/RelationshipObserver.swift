//
//  RelationshipObserver.swift
//  
//
//  Created by Daniel Eberle on 13.03.21.
//

import Foundation
import CoreData

public struct ObservationPattern: Equatable, Hashable {

    let entityName: String
    let relationshipKey: String

    public init(entityName: String, relationshipKey: String) {

        self.entityName = entityName
        self.relationshipKey = relationshipKey
    }

    func validate(for managedObjectModel: NSManagedObjectModel) -> Bool {

        guard let entity = managedObjectModel.entitiesByName[self.entityName]
              , let _ = entity.relationshipsByName[self.relationshipKey] else {

            assertionFailure("Chassis: relationship \(relationshipKey) not found on \(entityName)")
            return false
        }
        return true
    }
}

public class RelationshipObserver {

    enum RelationshipObservationError: Error {

        case missingManagedObjectModel
        case invalidObservationPattern
    }

    let objectContext: NSManagedObjectContext
    var observationPatterns: Set<ObservationPattern> = []

    init(objectContext: NSManagedObjectContext) {

        self.objectContext = objectContext
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: self.objectContext)
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    @objc func contextDidChange(_ notification: Notification) {

        self.observationPatterns.forEach { pattern in

            let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set()
            updatedObjects.filter( {$0.entity.name == pattern.entityName}).forEach {

                guard let instrument = $0.value(forKey: pattern.relationshipKey) as? NSManagedObject else { return }

                self.objectContext.refresh(instrument, mergeChanges: true)
            }
        }
    }

    public func add(_ observationPattern: ObservationPattern) throws {

        guard let objectModel = self.objectContext.persistentStoreCoordinator?.managedObjectModel else {

            throw RelationshipObservationError.missingManagedObjectModel
        }
        guard observationPattern.validate(for: objectModel) else {

            throw RelationshipObservationError.invalidObservationPattern
        }

        self.observationPatterns.insert(observationPattern)
    }

    public func remove(_ observationPattern: ObservationPattern) {

        self.observationPatterns.remove(observationPattern)
    }
}
