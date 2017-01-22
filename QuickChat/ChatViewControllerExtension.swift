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
    
    //override this funciton to create the color for text
    //get cell from parent's cell and return a new cell for another setting
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let singleMessage = message[indexPath.item]
        if singleMessage.senderId == senderId {
            cell.textView.textColor = UIColor.white
        }else{
            cell.textView.textColor = UIColor.black
        }
        return cell
    }
    
    //add message 
    func addMessage(id:String, name:String, text:String){
        if let newMessage = JSQMessage(senderId: id, displayName: name, text: text){
            message.append(newMessage)
        }
    }
    
    //handle when user input text
    override func textViewDidChange(_ textView: UITextView) {
        //? need?
        super.textViewDidChange(textView)
        // if text is not empty -> user enter some words
        isTyping = (textView.text != "")
    }
    
    //action press button to send message
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if let okChannel = channel{
        FireDatabaseAPI.default.wirteNewMessagetoChannel(channelID: okChannel.id, senderID: senderId, senderName: senderDisplayName, text: text)
        //display sending sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        //clear text field & look like to reload data
        finishSendingMessage()
        //set isTyping to false
        isTyping = false
        }else{
            print("Don't get any channel")
        }
    }
    
}
