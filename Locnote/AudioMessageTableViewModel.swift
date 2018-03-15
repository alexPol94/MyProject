//
//  AudioMessageTableViewModel.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 25.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit
import AVFoundation


class AudioMessageTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    // MARK: - Properties
    let cellReuseID = "soundMessageCellID"
    var soundMessages = [Data]()
    var isEditable: (() -> Bool)?
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditable!() {
            return self.soundMessages.count + 1
        }
        return self.soundMessages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID) as! AudioMessageTableViewCell
        cell.dataForPlayer = {
            let index = indexPath.row
            return self.soundMessages[index]
        }
        
        cell.saveRecordDataComplition = { soundData in
            self.soundMessages.append(soundData!)
        }

        cell.addNewRow = {
            let indexPath = IndexPath(row: numberOfRows, section: indexPath.section)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.top)
            tableView.endUpdates()
        }
        
        cell.setupAudioRecorder()
        // формируем последнюю ячейку для записи
        if indexPath.row == numberOfRows - 1 && isEditable!() {
            
            cell.typeOfCellAudio = AudioMessageTableViewCell.TypeOfAudioSession.recorder
            cell.timeCounter.text = "00:00"
        }
        // формируем ячейки для воспроизведения
        else {
            cell.typeOfCellAudio = AudioMessageTableViewCell.TypeOfAudioSession.player
            cell.setupAudioPlayer()
            cell.timeCounter.text = cell.stringFor(timeInterval: cell.soundPlayer.duration)
            
        }
        cell.setButtonImage()
        cell.progressBar.progress = 1.00
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isEditable!() {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
                return false
            }
            return true
        }
        return false
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            tableView.beginUpdates()
            self.soundMessages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.perform(#selector(tableView.reloadData), with: nil, afterDelay: 0.5)
            tableView.endUpdates()
            
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
}
