//
//  TableViewDataSource.swift
//  Chassis
//
//  Created by Daniel Eberle on 12.09.20.
//

import Foundation
import UIKit
import CoreData


open class TableViewDataSource<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource {

    public typealias CellProvider = (UITableView, IndexPath, T, UITableViewCell?) -> UITableViewCell

    var bulkOperationInProgress = true
    var ignoreUpdates = false
    let objectContext: NSManagedObjectContext
    var sortDescriptors: [NSSortDescriptor]
    var predicate: NSPredicate?
    let tableView: UITableView
    let cellProvider: CellProvider

    public var pauseAnimations = false

    public init(tableView: UITableView,
         objectContext: NSManagedObjectContext,
         sortDescriptors: [NSSortDescriptor]? = nil,
         predicate: NSPredicate? = nil,
         cellProvider: @escaping CellProvider) {

        self.objectContext = objectContext
        self.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(key: "objectID", ascending: false)]
        self.predicate = predicate
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        self.tableView.dataSource = self
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

    public func object(at indexPath: IndexPath) -> T {

        return self.fetchedResultsController.object(at: indexPath)
    }


    // MARK: - FRC
    
    public lazy var fetchedResultsController: NSFetchedResultsController<T> = {

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


    // MARK: - TableView Data Source

    public func numberOfSections(in tableView: UITableView) -> Int {

        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let managedObject: T = self.fetchedResultsController.object(at: indexPath)
        return self.cellProvider(self.tableView, indexPath, managedObject, nil)
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        switch editingStyle {
        case .delete:
            let managedObject = self.object(at: indexPath)
            self.objectContext.delete(managedObject)
        default:
            // unsupported commit editing case
            break
        }
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }


    // MARK: - FRC Delegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        self.tableView.beginUpdates()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        switch type {
        case .insert:
            self.tableView.insertSections([sectionIndex], with: .automatic)
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: .automatic)
        default:
            assertionFailure("Chassis: Unknown didChangeSection case.")
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            break;
        case .update:
            if let indexPath = newIndexPath ?? indexPath {

                guard let cell = self.tableView.cellForRow(at: indexPath) else {

                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    return
                }
                UIView.transition(with: cell,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: { [weak self] in
                                    guard let self = self else { return }
                                    let _ = self.cellProvider(self.tableView, indexPath, anObject as! T, cell)
                                  }, completion: nil)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.tableView.moveRow(at: indexPath, to: newIndexPath)
            }
            break;
        default:
            assertionFailure("Chassis: Unknown didChangeRow case.")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        self.tableView.endUpdates()
    }
}

