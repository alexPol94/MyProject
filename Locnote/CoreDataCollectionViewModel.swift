//
//  CoreDataCollectionViewModel.swift
//  Locnote
//
//  Created by Alexandr on 14.02.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit
import CoreData



class CoreDataCollectionViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    private var blockOperations: [BlockOperation] = []
//    var managedObjectContext: NSManagedObjectContext? = nil
    var managedObjectContext: NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    var collectionView: (() -> UICollectionView)? = nil

    var cachName:String? = nil
    
    private let reuseIdentifier: String
    private let  isFinished: Bool
    
    init(isNotificationIsComplited: Bool) {
        self.isFinished = isNotificationIsComplited
        
        if isNotificationIsComplited {
            self.reuseIdentifier = "CompletedCell"
        }
        else {
            self.reuseIdentifier = "CurrentCell"
        }
        super.init()
    }
    
    func deleteCell(at indexPath: IndexPath) {
        self.managedObjectContext!.delete(self.fetchedResultsController.object(at: indexPath))
        try! self.managedObjectContext!.save()
    }
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        self.clearBlockOperations()
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        if self.isFinished {
            return sectionInfo.numberOfObjects
        }
        return sectionInfo.numberOfObjects + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Notification> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate: NSPredicate = NSPredicate(format: "isFinished == \(self.isFinished.hashValue)")
        fetchRequest.predicate = predicate
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.managedObjectContext!,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: self.cachName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Notification>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.clearBlockOperations()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.addBlockOperation { [weak self] in
                if let this = self {
                        this.collectionView!().insertSections(IndexSet(integer: sectionIndex))
                }
            }
        case .delete:
            self.addBlockOperation { [weak self] in
                if let this = self {
                        this.collectionView!().deleteSections(IndexSet(integer: sectionIndex))
                }
            }
        case .update:
            self.addBlockOperation { [weak self] in
                if let this = self {
                    this.collectionView!().reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                }
            }
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.addBlockOperation { [weak self] in
                if let this = self {
                    this.collectionView!().insertItems(at: [newIndexPath!])
                }
            }
        case .delete:
            self.addBlockOperation { [weak self] in
                if let this = self {
                    this.collectionView!().deleteItems(at: [indexPath!])
                }
            }
        case .update:
            self.addBlockOperation { [weak self] in
                if let this = self {
                    this.collectionView!().reloadItems(at: [indexPath!])
                }
            }
        case .move:
            self.addBlockOperation { [weak self] in
                if let this = self {
                    this.collectionView!().moveItem(at: indexPath!, to: newIndexPath!)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!().performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.clearBlockOperations()
        })
    }
    
    func clearBlockOperations() {
        self.blockOperations.removeAll(keepingCapacity: false)
    }
    
    func addBlockOperation(operation: @escaping () -> Void) {
        self.blockOperations.append(BlockOperation(block: operation))
    }
    
    func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
    }

}
