//
//  CRDCoreDataStack.swift
//  PassBook
//
//  Created by Christopher Disdero on 1/22/17.
//  Copyright © 2017 Christopher Disdero. All rights reserved.
//

import CoreData

public protocol CRDCoreDataStackProtocol {
    
    /// Seeds the data store.
    func seedDataStore()
}

public class CRDCoreDataStack {
    
    // MARK: - Public constants
    
    /// Notification that the CRDCoreDataManager has been initialized.
    public static let notificationInitialized = "CRDCoreDataStack.notificationInitialized"
    
    /// Notification that the CRDCoreDataManager failed to initialize.
    public static let notificationInitializedFailed = "CRDCoreDataStack.notificationInitializedFailed"
    
    // MARK: - Private members
    
    /// The name of the data model to manage.
    private let modelName: String
    
    /// A reference to a class instance that implements CRDCoreDataStackProtocol.
    private let delegate: CRDCoreDataStackProtocol?
    
    // MARK: - Initializers
    
    public init(modelName: String, delegate: CRDCoreDataStackProtocol? = nil) {
        
        self.modelName = modelName
        self.delegate = delegate
        
        setupManager()
    }
    
    // MARK: - Public methods
    
    /// Creates a new private child context from the main context.
    public func privateChildManagedObjectContext() -> NSManagedObjectContext {
        
        // Initialize a new private queue child context.
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Make this context a child of the main thread managed object context.
        managedObjectContext.parent = mainManagedObjectContext
        
        return managedObjectContext
    }
    
    /// Saves any changes for both the main context and any child private contexts that were created.
    public func saveChanges(onError: @escaping (NSError?) -> ()) {
        
        // Save any changes made to the main managed object context to the private context.
        mainManagedObjectContext.performAndWait({
            
            do {
                
                if self.mainManagedObjectContext.hasChanges {
                    
                    try self.mainManagedObjectContext.save()
                }
                
            } catch let saveError as NSError {
                
                onError(saveError)
            }
        })
        
        // Save any changes in the private context to the persistent store in the background.
        privateManagedObjectContext.perform({
            
            do {
                
                if self.privateManagedObjectContext.hasChanges {
                    
                    try self.privateManagedObjectContext.save()
                }

            } catch let saveError as NSError {
                
                onError(saveError)
            }
        })
    }
    
    // MARK: - Public properties
    
    public private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        // Initialize the managed object context on the main queue.
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Make this context a child of the private managed object context.
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    // MARK: - Private methods
    
    private func setupManager() {
        
        let _ = mainManagedObjectContext.persistentStoreCoordinator
        
        DispatchQueue.global().async {
            
            guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
                
                DispatchQueue.main.async {
                    
                    // Send initialization failed notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CRDCoreDataStack.notificationInitializedFailed), object: self)
                }
                
                return
            }
            
            // Helper
            let persistentStoreURL = self.persistentStoreURL
            
            // Check if the persistent store exists and if not, set a flag to indicate we are creating it for the first time.
            var persistentStoreNewlyCreated = true
            do {
                
                persistentStoreNewlyCreated = !(try persistentStoreURL.checkResourceIsReachable())
            
            } catch {
                
                // Do nothing.
            }
            
            do {

                #if os(macOS)

                    let options = [
                        NSMigratePersistentStoresAutomaticallyOption : true,
                        NSInferMappingModelAutomaticallyOption : true,
                        NSSQLitePragmasOption : NSDictionary(dictionary: ["journal_mode": "DELETE"])
                        ] as [String : Any]

                #else

                    let options = [
                        NSMigratePersistentStoresAutomaticallyOption : true,
                        NSInferMappingModelAutomaticallyOption : true,
                        NSPersistentStoreFileProtectionKey : FileProtectionType.complete,
                        NSSQLitePragmasOption : NSDictionary(dictionary: ["journal_mode": "DELETE"])
                        ] as [String : Any]

                #endif

                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
                
            } catch let error as NSError {
                
                DispatchQueue.main.async {
                    
                    // Send initialization failed notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CRDCoreDataStack.notificationInitializedFailed), object: self, userInfo:["error": error])
                }
                
                return
            }
            
            DispatchQueue.main.async {
                
                // Seed the database if the persistent store was newly created.
                if persistentStoreNewlyCreated {
    
                    if let delegate = self.delegate {
                        
                        delegate.seedDataStore()
                    }
                }
                
                // Send initialization notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: CRDCoreDataStack.notificationInitialized), object: self)
            }
        }
    }
    
    // MARK: - Private properties
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        
        // Get the data model url given the model name as specified in this class initializer.
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            
            // No data model file with the name specified exists, so return nil to indicate error.
            return nil
        }
        
        // Initialize the managed object model with the model url.
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        
        return managedObjectModel
    }()
    
    private var persistentStoreURL: URL {
        
        // Compute the persistent store name based on the specified model name.
        let storeName = "\(modelName).sqlite"
        
        // Return the fully qualified url to the persistent store file.
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(storeName)
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        // If there is no valid managed object model, then return nil to indicate error.
        guard let managedObjectModel = self.managedObjectModel else {
            
            return nil
        }
        
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        return persistentStoreCoordinator
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        
        // Initialize the managed object context on a private queue.
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Assign the persistent store coordinator to this context.
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
}
