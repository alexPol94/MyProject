//
//  NotFinishedNotificationCollectionViewModel.swift
//  Locnote
//
//  Created by Alexandr on 14.02.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit

class CurrentNotificationCollectionViewModel: CoreDataCollectionViewModel {
    
    var addNewNotification: (() -> Void)? = nil
    var goToSendToMeNote: ((SendToMeNote) -> Void)? = nil
    var goToSendToContactNote: ((SendToContactNote) -> Void)? = nil
    init() {
        super.init(isNotificationIsComplited: false)
        self.cachName = "Master"
    }
    
    override func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        let sectionInfo = self.fetchedResultsController.sections![indexPath.section]
        if indexPath.item < sectionInfo.numberOfObjects {
            let note: Notification = self.fetchedResultsController.object(at: indexPath)
            let name = note.placeLocation?.title
            let message = note.message?.text
            
            let object = self.fetchedResultsController.object(at: indexPath)
            if object is SendToMeNote {
                cell.backgroundColor = UIColor.green
            }
            else if object is SendToContactNote {
                cell.backgroundColor = UIColor.yellow
            }
            
            (cell as! CurrentCollectionViewCell).nameLabel.text = name
            (cell as! CurrentCollectionViewCell).messageLabel.text = message
            (cell as! CurrentCollectionViewCell).imageView.image = nil
        }
        else {
            (cell as! CurrentCollectionViewCell).imageView.image = UIImage(named: "plus")
            (cell as! CurrentCollectionViewCell).backgroundColor = UIColor(red:0.96, green:0.42, blue:0.11, alpha:1.0)
            (cell as! CurrentCollectionViewCell).nameLabel.text = ""
            (cell as! CurrentCollectionViewCell).messageLabel.text = ""
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let numberOfLastItem = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if indexPath.item == numberOfLastItem {
            self.addNewNotification!()
        }
        else if indexPath.item < numberOfLastItem {
            let object = self.fetchedResultsController.object(at: indexPath)
            if let sendToMeNote = object as? SendToMeNote {
                self.goToSendToMeNote!(sendToMeNote)
            }
            else if let sendToContactNote = object as? SendToContactNote {
                self.goToSendToContactNote!(sendToContactNote)
            }
        }
    }
}
