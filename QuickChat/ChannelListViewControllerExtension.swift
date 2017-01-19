//
//  ChannelListViewControllerExtension.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 16/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GSMessages

extension ChannelListViewController{

    func initialViewDidLoad(){
        // tableView's deledate & dataSource
        channelListTableView.dataSource = self
        channelListTableView.delegate = self
        
        //register xib
        channelListTableView.register(UINib(nibName: "NewChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "NewChannel")
        channelListTableView.register(UINib(nibName: "ExistingChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ExistingChannel")
        
        //read exist channel from cloud database
        cloudDatabaseManger.readFromCloud {
        (channelData) in
            self.channel.append(channelData)
            print("cannel count\(self.channel.count)")
            DispatchQueue.main.async {
                self.channelListTableView.reloadData()
            }
        }
        
    }
}

extension ChannelListViewController:UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    // only need one cell for create new channel
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection:Section = Section(rawValue: section){
            switch currentSection{
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channel.count
            }
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseCellId = indexPath.section == Section.createNewChannelSection.rawValue ? "NewChannel":"ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
        
        if indexPath.section == Section.createNewChannelSection.rawValue {
            let newChannelCell = cell as! NewChannelTableViewCell
            newChannelTextField = newChannelCell.newChannelNameTextField
            //delegate for tableView button touch action
            newChannelCell.delegate = self
            newChannelCell.newChannelNameTextField.delegate = self
        }else{
            let existingChannel = cell as! ExistingChannelTableViewCell
            existingChannel.channelNameLabel.text = channel[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //close the keyboard
        tableView.endEditing(true)
        
        //push to ChatViewController
        if Section.currentChannelsSection.rawValue == indexPath.section {
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            view.channel = channel[indexPath.row]
            if let displayname = UserDefaults.standard.string(forKey: "displayName"){
                view.senderDisplayName = displayname
            }else{
                view.senderDisplayName = "Unknow"
            }
            navigationController?.pushViewController(view, animated: true)
        }
    }
}

extension ChannelListViewController:NewChannelTableViewCellDelegate{
    func createNewChannelAction(){
        if let name = newChannelTextField?.text, !name.isEmpty {
            cloudDatabaseManger.wirteNewChannelToCloud(name: name)
        }else{
            self.showMessage("Please enter the name of new channel.", type: .error, options: [.animation(.slide), .animationDuration(0.3), .height(32),.hideOnTap(true)])
        }
    }
}

extension ChannelListViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
