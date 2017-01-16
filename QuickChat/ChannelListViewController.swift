//
//  ChannelListViewController.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 16/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit

class ChannelListViewController: UIViewController {
    
    @IBOutlet weak var channelListTableView: UITableView!
    internal var channel:[Channel] = []
    var newChannelTextField:UITextField?
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
