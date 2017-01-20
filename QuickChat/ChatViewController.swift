//
//  ChatViewController.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 18/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

final class ChatViewController: JSQMessagesViewController {

    //set navigation title when setting the channel
    var channel:Channel?{
        didSet{
            self.title = self.channel?.name
        }
    }
    
    //store message array
    var message:[JSQMessage] = []
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    //DI injection -> for testing
    var cloudDatabaseManger:CloudDatabaseAble = FireDatabaseAPI.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get sender's unique id by get login uid
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        //get sender's display from userdefault
        if let okDisplayName = UserDefaults.standard.string(forKey: "displayName"){
            self.senderDisplayName = okDisplayName
        }
        //remove avatar view
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //let message to keep update
        if let channelID = channel?.id {
        cloudDatabaseManger.readMessageFromChannel(channelID: channelID, completion: {
            (senderID, senderName, text) in
            self.addMessage(id: senderID, name: senderName, text: text)
            // tell JSQ there is new data to display
            self.finishReceivingMessage()
        })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
