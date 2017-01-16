//
//  ChannelListViewController.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 16/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChannelListViewController: UIViewController {
    
    @IBOutlet weak var channelListTableView: UITableView!
    internal var channel:[Channel] = []
    var newChannelTextField:UITextField?
    
    var cloudDatabaseManger:CloudDatabaseAble = FireDatabaseAPI.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //test for tableview
        let channel1 = Channel(name: "gogogo", id: "ch1")
        let channel2 = Channel(name: "notototo", id: "ch2")
        let channel3 = Channel(name: "jijiji", id: "ch3")
        
        channel.append(channel1)
        channel.append(channel2)
        channel.append(channel3)
        
        
        initialViewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
