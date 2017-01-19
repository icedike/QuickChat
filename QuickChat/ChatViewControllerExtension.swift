//
//  ChatViewControllerExtension.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 19/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//


import UIKit
import JSQMessagesViewController

extension ChatViewController{
    
    //give message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return message[indexPath.item]
    }
    //know how many messages to show
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message.count
    }
}
