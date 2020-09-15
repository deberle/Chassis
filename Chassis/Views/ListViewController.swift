//
//  ListViewController.swift
//  Chassis
//
//  Created by Daniel Eberle on 15.09.20.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {

    // smell – should get this via DI
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistenceController.viewContext

    let reuseIdentifier = "Cell"
    var diffableDataSource: TableViewControllerDataSource<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        self.diffableDataSource = TableViewControllerDataSource<Item>(tableView: tableView,
                                                                                objectContext: managedObjectContext,
                                                                                sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) { (tableView, indexPath, itemId) -> UITableViewCell? in

            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
            let item = self.managedObjectContext.registeredObject(for: itemId) as? Item
            cell.textLabel?.text = item?.title
            if let timestamp = item?.timestamp {

                cell.detailTextLabel?.text = String(describing: timestamp)
            }
            return cell
        }

        self.diffableDataSource?.performInitialFetch()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let objectID = self.diffableDataSource?.itemIdentifier(for: indexPath) else { return }

        let event = RoutingEvent(viewController: self, route: .detailView(objectID))
        UIApplication.shared.sendAction(#selector(Router.route(sender:event:))
                                        , to: nil, from: tableView, for: event)
    }
}

