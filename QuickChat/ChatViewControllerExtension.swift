//
//  ChatViewControllerExtension.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 19/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//


import UIKit
import JSQMessagesViewController
import Photos
import FirebaseStorage

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
            cell.textView?.textColor = UIColor.white
        }else{
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    //add message 
    func addMessage(id:String, name:String, text:String){
        if let newMessage = JSQMessage(senderId: id, displayName: name, text: text){
            message.append(newMessage)
        }
    }
    
    //add photo message
    func addPhotoMessage(id: String, name: String, mediaItem: JSQPhotoMediaItem, key: String){
        if let newPhotoMessage = JSQMessage(senderId: id, displayName: name, media: mediaItem){
            message.append(newPhotoMessage)
            
            // save meditaItem for updating image later
            if mediaItem.image == nil {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // fetch image from URL
    func fetchImageAtURL(_ photoURL: String,
                         forMediaItem mediaItem: JSQPhotoMediaItem,
                         clearPhotoMessageMapKey key: String){
        //check whether is a valid url 
        if photoURL.hasPrefix("gs://"){
            cloudDatabaseManger.getImageAtStroageURL(photoURL) { (newImage) in
                mediaItem.image = newImage
                // reload data after geting new image
                self.collectionView.reloadData()
                // remove the photoMessage data
                self.photoMessageMap.removeValue(forKey: key)
            }

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
        cloudDatabaseManger.wirteNewMessagetoChannel(channelID: okChannel.id, senderID: senderId, senderName: senderDisplayName, text: text)
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
    
    // press add picture button
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
}

extension ChatViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // get photo url if the photo from photoalbum
        if let photoRefenenceURL = info[UIImagePickerControllerReferenceURL] as? URL {
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoRefenenceURL], options: nil)
            let asset = assets.firstObject
            print("photoRefenceURL:\(photoRefenenceURL)")
            
            if let channelID = channel?.id{
                let key = cloudDatabaseManger.setInitialPhotoURL(channelID: channelID, senderID: senderId)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                finishSendingMessage()
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    print("imageFileURL:\(imageFileURL)")
                    
                    let path = "\(self.senderId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoRefenenceURL.lastPathComponent)"
                    
                    self.cloudDatabaseManger.savePhotoToStorage(path: path, imageFileURL: imageFileURL!, completion: { (metaData, error) in
                        if error != nil {
                            print("Error uploading photo:\(error?.localizedDescription)")
                            return
                        }
                        self.cloudDatabaseManger.updatePhotoURL(channelID: channelID, key: key, metaData: metaData)
                    })
                    
                })
            }
        }else{
            // a photo from camera
            print("choose photo from the camera ")
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if let channelID = channel?.id{
                let key = cloudDatabaseManger.setInitialPhotoURL(channelID: channelID, senderID: senderId)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                finishSendingMessage()
                //compress image size
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let imagePath = "\(senderId!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                print("imagePath:\(imagePath)")
                cloudDatabaseManger.savePotoToStorageFromCamera(path: imagePath, imageData: imageData){
                    (metaData, error) in
                    if error != nil {
                        print("Error uploading photo:\(error?.localizedDescription)")
                        return
                    }
                    self.cloudDatabaseManger.updatePhotoURL(channelID: channelID, key: key, metaData: metaData)
                }
                
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
