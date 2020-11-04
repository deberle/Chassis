//
//  PersistenceController.swift
//  Chassis
//
//  Created by Daniel Eberle on 15.09.20.
//

import CoreData
import UIKit


open class DataEvent: UIEvent {
    
    let objectID: NSManagedObjectID
    
    init(objectID: NSManagedObjectID) {
        
        self.objectID = objectID
        super.init()
    }
}

open class PersistenceController: AppModule {


    // MARK: - Core Data stack
    
    let container: NSPersistentContainer
    public var viewContext:  NSManagedObjectContext { container.viewContext }
    
    public init(inMemory: Bool = false, databaseName: String) {

        container = NSPersistentContainer(name: databaseName)
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

    // MARK: - Actions

    @IBAction public func deleteObject(sender: Any?, event: DataEvent) {
        
        guard let object = try? container.viewContext.existingObject(with: event.objectID) else { return }
        container.viewContext.delete(object)
    }
    
    @IBAction public func saveContext(sender: Any?, event: UIEvent) {
        
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
    
    public func createObject<T: NSManagedObject>() -> T {
        
        let newObject = T(context: self.viewContext)
        return newObject
    }
}