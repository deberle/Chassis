//
//  PersistenceController.swift
//  Chassis
//
//  Created by Daniel Eberle on 15.09.20.
//

import CoreData
import UIKit


class DataEvent: UIEvent {

    let objectID: NSManagedObjectID

    init(objectID: NSManagedObjectID) {

        self.objectID = objectID
        super.init()
    }
}

class PersistenceController: AppModule {

    // MARK: - Setup

    convenience override init() {

#if DEBUG
        self.init(inMemory: true)
        for i in 0..<10 {

            let newItem: Item = self.createObject()
            newItem.timestamp = Date()
            newItem.title = "Item \(i)"
        }
        self.saveContext(sender: nil, event: UIEvent())
#else
        self.init(inMemory: false)
#endif
    }


    // MARK: - Actions

    @IBAction func createItem(sender: Any?, event: UIEvent) {

        let newItem: Item = self.createObject()
        newItem.timestamp = Date()
        newItem.title = "New Item"
    }

    @IBAction func deleteObject(sender: Any?, event: DataEvent) {

        guard let object = try? container.viewContext.existingObject(with: event.objectID) else { return }
        container.viewContext.delete(object)
    }

    @IBAction func saveContext(sender: Any?, event: UIEvent) {

        let context = container.viewContext
        if context.hasChanges {
            do {

                try context.save()
            } catch {

                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        print("Context saved.")
    }

    func createObject<T: NSManagedObject>() -> T {
        
        let newObject = T(context: self.viewContext)
        return newObject
    }

    // MARK: - Core Data stack

    let container: NSPersistentContainer
    var viewContext:  NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(name: "Chassis")
        if inMemory {

            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
