//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQDataSourcesKit/
//
//
//  GitHub
//  https://github.com/jessesquires/JSQDataSourcesKit
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import CoreData

//  A quick and dirty core data stack, don't do this

public class CoreDataStack {
    
    public let context: NSManagedObjectContext
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    public init(inMemory: Bool = false) {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        
        let model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let documentsDirectoryURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)
        
        let storeURL = documentsDirectoryURL!.URLByAppendingPathComponent("Model.sqlite")
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        persistentStoreCoordinator.addPersistentStoreWithType(inMemory ? NSInMemoryStoreType : NSSQLiteStoreType,
            configuration: nil, URL: inMemory ? nil : storeURL, options: nil, error: nil)
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }

    public func saveAndWait() -> Bool {
        if !self.context.hasChanges {
            return true
        }

        var success = false
        self.context.performBlockAndWait { () -> Void in
            var error: NSError?
            success = self.context.save(&error)

            if !success {
                println("*** Error saving managed object context: \(error)")
            }
        }
        return success
    }

}
