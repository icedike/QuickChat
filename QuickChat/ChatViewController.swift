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
    
    
    var localIsTyping:Bool = false
    
    var isTyping:Bool{
        get{
            return localIsTyping
        }
        set(newValue){
            // update to local and firebase
            localIsTyping = newValue
            cloudDatabaseManger.setIsTypingInChannel(channelID: (channel?.id)!, senderID: senderId, isTyping: newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
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

            // set to remove isTyping value when user logged out
            cloudDatabaseManger.setDoDisconnectRemoveIsTyping(channelID: channelID, senderID: senderId)
            

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //change from viewdid load to view will appear
        if let channelID = channel?.id{
            cloudDatabaseManger.readMessageFromChannel(channelID: channelID, completion: {
                (senderID, senderName, text) in
                self.addMessage(id: senderID, name: senderName, text: text)
                // tell JSQ there is new data to display
                self.finishReceivingMessage()
            })
            
            // add observe to check whether other people were typing
            cloudDatabaseManger.observeIsTypingInChannel(channelID: channelID, isTyping:{
                //return isTyping status when observe get the update value
                return self.isTyping
            }, completion: { (isOtherTyping) in
                
                self.showTypingIndicator = isOtherTyping
                self.scrollToBottom(animated: isOtherTyping)
                
            })
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("remove observe")
        if let channelID = channel?.id{
            cloudDatabaseManger.removeObserve()
            cloudDatabaseManger.removeMessageObserve(channelID:channelID)
        }
    }
    
    deinit {
        print("ChatViewController deinit")
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
