//
//  FireDataBaseAPI.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 17/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

protocol CloudDatabaseAble {
    func wirteNewChannelToCloud(name:String)
    
    func wirteNewMessagetoChannel(channelID:String, senderID:String, senderName:String, text:String)
    
    func readFromCloud(readHandler:@escaping (Channel) -> Void)
    
    func readMessageFromChannel(channelID:String, completion:@escaping (String, String, String) -> Void)
    
    func removeObserve()
    
    func removeMessageObserve(channelID:String)
}

// calss for habdleing firedabase API

class FireDatabaseAPI:CloudDatabaseAble{
    
    private init(){
    }
    
    static let `default` = FireDatabaseAPI()
    
    private lazy var channelRef:FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    
    
    // write a channel to firebase API
    func wirteNewChannelToCloud(name:String) {
        print("save data to firebase")
        let referByAutoId = channelRef.childByAutoId()
        let channelItem = ["name":name]
        referByAutoId.setValue(channelItem)
    }
    
    // write a message to a specified channel in firebase API
    func wirteNewMessagetoChannel(channelID:String, senderID:String, senderName:String, text:String){
        print("save message to the channel")
        let referByAutoID = channelRef.child("\(channelID)/messages").childByAutoId()
        let messageItem = ["senderID":senderID,"senderName":senderName,"text":text]
        referByAutoID.setValue(messageItem)
    }
    
    //variable to handle the FIRDatabase
    private var channelHandle:FIRDatabaseHandle?
    // read a channel from firebase API
    func readFromCloud(readHandler:@escaping (Channel) -> Void) {
        channelHandle = channelRef.observe(.childAdded, with: {
            (snapShot) in
            //make sure that adding a new child would not pass a nil snapshot
            let channelJSONData = JSON(snapShot.value!)
            let id = snapShot.key
            
            //check that name is not  empty 
            if let name = channelJSONData["name"].string, !name.isEmpty{
                print("exist channel: \(name), id :\(id)")
                readHandler(Channel(name: name, id: id))
            }else{
                print("fail to get the name of the channel")
            }
        })
    }
    
    private var messageHandle:FIRDatabaseHandle?
    //read a message from channel
    func readMessageFromChannel(channelID:String, completion:@escaping (_ senderID:String, _ senderName:String,_ text:String) -> Void){
        print("read message form channle in the cloud")
        let messageRef = channelRef.child("\(channelID)/messages")
        //limit the number message we need to read
        let messageRefQuery = messageRef.queryLimited(toLast: 25)
        messageHandle = messageRefQuery.observe(.childAdded, with: {
            (snapShot) in
            let messageJSONData = JSON(snapShot.value!)
            
            if let senderID = messageJSONData["senderID"].string,  let senderName = messageJSONData["senderName"].string, let text = messageJSONData["text"].string, !text.isEmpty {
                completion(senderID, senderName, text)
            }else{
                print("fail to get the message from channel")
            }
        })
    }
    // not every API would remove the observe
    // would not include in protocol
    // remove observe when view deinit
    // however, it would be much eaiser to replace the API or test
    // just not implement this function
    func removeObserve(){
        if let channelHandle = channelHandle{
            channelRef.removeObserver(withHandle: channelHandle)
        }
    }
    
    //remove message observe
    func removeMessageObserve(channelID:String){
        if let messageHandle = messageHandle{
            let messageRef = channelRef.child("\(channelID)/messages")
            messageRef.removeObserver(withHandle: messageHandle)
        }
    }
}
