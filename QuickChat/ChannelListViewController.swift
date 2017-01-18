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
    
    //DI injection -> for testing 
    var cloudDatabaseManger:CloudDatabaseAble = FireDatabaseAPI.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call function to initial all setting
        initialViewDidLoad()
    }
    
    deinit {
        // remove the observe 
       cloudDatabaseManger.removeObserve()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
