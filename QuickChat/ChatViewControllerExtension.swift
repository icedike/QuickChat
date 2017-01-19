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
    
    // set bubble color -> use lazy
//    func setUpOutgoingBubble() -> JSQMessagesBubbleImage{
//        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//    }
//    func setUpIncomingBubble() -> JSQMessagesBubbleImage{
//        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
//    }
    
    // set bubble image
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let singleMessage = message[indexPath.item]
        if singleMessage.senderId == self.senderId {
            return outgoingBubbleImageView
        }else{
            return incomingBubbleImageView
        }
    }
    //remove avatar image datasource
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
}
