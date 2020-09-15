//
//  TableViewControllerDataSource.swift
//  Chassis
//
//  Created by Daniel Eberle on 12.09.20.
//

import Foundation
import UIKit
import CoreData


class TableViewControllerDataSource<T: NSManagedObject>: UITableViewDiffableDataSource<String, NSManagedObjectID>, NSFetchedResultsControllerDelegate {

    var setupInProgress = true
    let objectContext: NSManagedObjectContext
    var sortDescriptors: [NSSortDescriptor]

    init(tableView: UITableView,
         objectContext: NSManagedObjectContext,
         sortDescriptors: [NSSortDescriptor],
         cellProvider: @escaping UITableViewDiffableDataSource<String, NSManagedObjectID>.CellProvider) {

        self.objectContext = objectContext
        self.sortDescriptors = sortDescriptors
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    func performInitialFetch() {

        do {

            try self.fetchedResultsController.performFetch()
            self.setupInProgress = false
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

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.objectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "Master")
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        self.apply(snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, animatingDifferences: !setupInProgress)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

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

