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
    
    func readFromCloud()
}

class FireDatabaseAPI:CloudDatabaseAble{
    
    private init(){
    }
    
    static let `default` = FireDatabaseAPI()
    
    private var channelRef:FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    
    func wirteNewChannelToCloud(name:String) {
        print("save data to firebase")
        let referByAutoId = channelRef.childByAutoId()
        let channelItem = ["name":name]
        referByAutoId.setValue(channelItem)
    }
    
    func readFromCloud() {
        
    }
}
