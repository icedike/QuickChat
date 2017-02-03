//
//  FireDataBaseAPI.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 17/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SwiftyJSON
import JSQMessagesViewController
import SwiftGifOrigin

protocol CloudDatabaseAble {
    func wirteNewChannelToCloud(name:String)
    
    func wirteNewMessagetoChannel(channelID:String, senderID:String, senderName:String, text:String)
    
    func readFromCloud(readHandler:@escaping (Channel) -> Void)
    
    func readMessageFromChannel(channelID:String, completion:@escaping (String, String, String) -> Void, completionForImage:@escaping (_ senderId: String, _ imageURL: String, _ key: String) -> Void)
    
    func setIsTypingInChannel(channelID:String, senderID:String, isTyping: Bool)
    
    func setDoDisconnectRemoveIsTyping(channelID:String, senderID:String)
    
    func observeIsTypingInChannel(channelID:String, isTyping:@escaping () -> Bool, completion:@escaping (Bool) -> Void)
    
    func savePhotoToStorage(path:String, imageFileURL:URL, completion:@escaping (FIRStorageMetadata?, Error?) -> Void)
    
    func savePotoToStorageFromCamera(path:String, imageData:Data?, completion:@escaping (FIRStorageMetadata?, Error?) -> Void)
    
    func setInitialPhotoURL(channelID:String, senderID:String) -> String
    
    func updatePhotoURL(channelID:String, key:String, metaData:FIRStorageMetadata?)
    
    func getImageAtStroageURL(_ photoURL: String, completion: @escaping (UIImage?) -> Void)
    
    func removeObserve()
    
    func removeMessageObserve(channelID:String)
}

// calss for habdleing firedabase API

class FireDatabaseAPI:CloudDatabaseAble{
    
    private init(){
    }
    
    static let `default` = FireDatabaseAPI()
    
    private lazy var channelRef:FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    
    private lazy var storageRef:FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://quickchat-96266.appspot.com")
    
    
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
    private var updateMessageHandle:FIRDatabaseHandle?
    //read a message from channel
    func readMessageFromChannel(channelID: String, completion:@escaping (_ senderID: String, _ senderName:String,_ text: String) -> Void, completionForImage:@escaping (_ senderId: String, _ imageURL: String, _ key: String) -> Void){
        print("read message form channle in the cloud")
        let messageRef = channelRef.child("\(channelID)/messages")
        //limit the number message we need to read
        let messageRefQuery = messageRef.queryLimited(toLast: 25)
        messageHandle = messageRefQuery.observe(.childAdded, with: {
            (snapShot) in
            let messageJSONData = JSON(snapShot.value!)
            
            if let senderID = messageJSONData["senderID"].string,  let senderName = messageJSONData["senderName"].string, let text = messageJSONData["text"].string, !text.isEmpty {
                //text message
                completion(senderID, senderName, text)
            }else if let senderIDFormImage = messageJSONData["senderID"].string, let photoURL = messageJSONData["photoURL"].string{
                // photo message
                completionForImage(senderIDFormImage, photoURL, snapShot.key)
                
            }else{
                print("fail to get the message from channel")
            }
        })
        
        // get update photoimage URL
        updateMessageHandle = messageRefQuery.observe(.childChanged, with: {
            (snapShot) in
            let messageJSONData = JSON(snapShot.value!)
            if let senderIDFormImage = messageJSONData["senderID"].string, let photoURL = messageJSONData["photoURL"].string{
                // photo message
                completionForImage(senderIDFormImage, photoURL, snapShot.key)
                
            }else{
                print("fail to get the updating image url")
            }
        })
        
    }
    
    // set value for type or not in firebase
    func setIsTypingInChannel(channelID:String, senderID:String, isTyping: Bool){
        let isTypingRef = channelRef.child("\(channelID)/typingIndicator/\(senderID)")
        isTypingRef.setValue(isTyping)
    }
    
    // set remove isTyping data from firebase if user disconnect
    func setDoDisconnectRemoveIsTyping(channelID:String, senderID:String){
        let isTypingRef = channelRef.child("\(channelID)/typingIndicator/\(senderID)")
        isTypingRef.onDisconnectRemoveValue()
    }
    
    // add observe for other peoople typing
    private var isTypingHandle:FIRDatabaseHandle?
    func observeIsTypingInChannel(channelID:String, isTyping:@escaping () -> Bool, completion:@escaping (_ otherTyping:Bool) -> Void){
        let isTypeingQueryRef = channelRef.child("\(channelID)/typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
        isTypingHandle = isTypeingQueryRef.observe(.value, with: {
            (snapShot) in
            if snapShot.childrenCount == 1 && isTyping() {
                return
            }
            
            completion(snapShot.childrenCount > 0)
        })
    }
    
    // save image to firebase storage
    func savePhotoToStorage(path:String, imageFileURL:URL, completion:@escaping (FIRStorageMetadata?, Error?) -> Void){
        storageRef.child(path).putFile(imageFileURL, metadata: nil) { (metadata, error) in
            completion(metadata, error)
        }
    }
    
    // save image to firebase storage from camera
    func savePotoToStorageFromCamera(path:String, imageData:Data?, completion:@escaping (FIRStorageMetadata?, Error?) -> Void){
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.child(path).put(imageData!, metadata: metaData) { (metadata, error) in
            completion(metadata, error)
        }
    }
    
    // will update photoURL after receiving the URL from firebaseStorage
    func setInitialPhotoURL(channelID:String, senderID:String) -> String {
        let photoRef = channelRef.child("\(channelID)/messages").childByAutoId()
        let photoItem = [
            "photoURL": "NOTSET",
            "senderID":senderID
        ]
        photoRef.setValue(photoItem)
        
        return photoRef.key
    }
    
    //update photoURL
    func updatePhotoURL(channelID:String, key:String, metaData:FIRStorageMetadata?){
        let photoRef = channelRef.child("\(channelID)/messages/\(key)")
        let validURL = storageRef.child((metaData?.path)!).description
        photoRef.updateChildValues(["photoURL":validURL])
    }

    //get image by url
    func getImageAtStroageURL(_ photoURL: String, completion: @escaping (UIImage?) -> Void){
        let imageStorageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        imageStorageRef.data(withMaxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("fail to get the iamge from the storage with url:\(error.localizedDescription)")
                return
            }
            
            imageStorageRef.metadata(completion: { (metadata, metadataError) in
                if let error = metadataError {
                    print("faile to gee metadata \(error.localizedDescription)")
                    return
                }
                
                let newImage:UIImage?
                if metadata?.contentType == "image/gif" {
                    newImage = UIImage.gif(data: data!)
                }else{
                    newImage = UIImage.init(data: data!)
                }
                completion(newImage)
            })
        }
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
    
    //remove message observe & isTyping observe
    func removeMessageObserve(channelID:String){
        if let messageHandle = messageHandle{
            let messageRef = channelRef.child("\(channelID)/messages")
            messageRef.removeObserver(withHandle: messageHandle)
        }
        
        if let updateMessageHandle = updateMessageHandle{
        let updateMessageRef = channelRef.child("\(channelID)/messages")
            updateMessageRef.removeObserver(withHandle: updateMessageHandle)
        }
        
        //may not need this -> because typingIndicator would delete when user logout?
        if let isTypingHandle = isTypingHandle{
            let isTypeingQueryRef = channelRef.child("\(channelID)/typingIndicator")
            isTypeingQueryRef.removeObserver(withHandle: isTypingHandle)
        }
        
    }
}
