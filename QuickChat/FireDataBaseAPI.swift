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
    
    func readFromCloud(readHandler:@escaping (Channel) -> Void)
    
    func removeObserve()
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
    
    //variable to handle the FIRDatabase
    private var channelHandel:FIRDatabaseHandle?
    // read a channel from firebase API
    func readFromCloud(readHandler:@escaping (Channel) -> Void) {
        channelHandel = channelRef.observe(.childAdded, with: {
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
    // not every API would remove the observe
    // would not include in protocol
    // remove observe when view deinit
    // however, it would be much eaiser to replace the API or test
    // just not implement this function
    func removeObserve(){
        if let channelHandel = channelHandel{
            channelRef.removeObserver(withHandle: channelHandel)
        }
    }
}
