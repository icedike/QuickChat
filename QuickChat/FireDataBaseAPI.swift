//
//  FireDataBaseAPI.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 17/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CloudDatabaseAble {
    func wirteNewChannelToCloud(name:String)
    
    func readFromCloud(readHandler:(Channel) -> Void)
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
    func readFromCloud(readHandler:(Channel) -> Void) {
        channelHandel = channelRef.observe(.childAdded, with: {
            (snapShot) in
            
        })
    }
}
