//
//  NewChannelTableViewCell.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 16/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit

protocol NewChannelTableViewCellDelegate:NSObjectProtocol{
    func createNewChannelAction()
}

class NewChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var newChannelNameTextField: UITextField!
    weak var delegate: NewChannelTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func createNewChannelBtnAction(_ sender: UIButton) {
        // create a new channel 
        delegate?.createNewChannelAction()
        // clearn textField after creating a new channel
        newChannelNameTextField.text = ""
    }
    
}
