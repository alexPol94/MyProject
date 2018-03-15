//
//  FinishedNotificationCollectionViewModel.swift
//  Locnote
//
//  Created by Alexandr on 14.02.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit

class ComplitedNotificationCollectionViewModel: CoreDataCollectionViewModel {
    
    init() {
        super.init(isNotificationIsComplited: true)
        
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

    
}
