//
//  TableViewDataSource.swift
//  Chassis
//
//  Created by Daniel Eberle on 12.09.20.
//

import Foundation
import UIKit
import CoreData


open class TableViewDataSource<T: NSManagedObject>: UITableViewDiffableDataSource<String, NSManagedObjectID>, NSFetchedResultsControllerDelegate {

    var bulkOperationInProgress = true
    var ignoreUpdates = false
    let objectContext: NSManagedObjectContext
    var sortDescriptors: [NSSortDescriptor]
    var predicate: NSPredicate?

    public init(tableView: UITableView,
         objectContext: NSManagedObjectContext,
         sortDescriptors: [NSSortDescriptor],
         predicate: NSPredicate? = nil,
         cellProvider: @escaping UITableViewDiffableDataSource<String, NSManagedObjectID>.CellProvider) {

        self.objectContext = objectContext
        self.sortDescriptors = sortDescriptors
        self.predicate = predicate
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    open func performInitialFetch() {

        do {

            try self.fetchedResultsController.performFetch()
            self.bulkOperationInProgress = false
        } catch {

            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - FRC
    
    lazy var fetchedResultsController: NSFetchedResultsController<T> = {

        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = self.sortDescriptors
        fetchRequest.predicate = self.predicate

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.objectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "Master")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        self.apply(snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, animatingDifferences: !bulkOperationInProgress)
    }
    
    
    // MARK: - UITableViewDataSource
    
    open override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard let objectID = self.itemIdentifier(for: sourceIndexPath),
              let object = try? self.objectContext.existingObject(with: objectID) as? T,
              var objects = self.fetchedResultsController.fetchedObjects else { return }

        objects.remove(at: sourceIndexPath.row)
        objects.insert(object, at: destinationIndexPath.row)

        bulkOperationInProgress = true
        
        for (index, item) in objects.enumerated() {

            item.setValue(index, forKeyPath: "sortOrder")
        }
        objectContext.refreshAllObjects()
        bulkOperationInProgress = false
    }
    
    open override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

        return T.entity().attributesByName["sortOrder"] != nil
            && fetchedResultsController.fetchedObjects?.count ?? 0 > 1
    }
    

    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    
    @objc open override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            guard let objectID = self.itemIdentifier(for: indexPath) else { return }
            let event = DataEvent(objectID: objectID)
            UIApplication.shared.sendAction(#selector(PersistenceController.deleteObject(sender:event:))
                                            , to: nil, from: tableView, for: event)
        }
    }
}

