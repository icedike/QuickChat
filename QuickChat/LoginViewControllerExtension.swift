//
//  LoginViewControllerExtension.swift
//  QuickChat
//
//  Created by LIN TINGMIN on 16/01/2017.
//  Copyright © 2017 MarkRobotDesign. All rights reserved.
//

import UIKit

extension LoginViewController{
    
    //close the keyboard when touch screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func initialViewDidLoad(){
        
        //set textfield delegate
        nameTextField.delegate = self
        
        //add observe to know when keyboaed show up or hide
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveView), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.backView), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    func login(){
        
    }
    
    func moveView(notification:Notification){
        print("move view")
        let userInfo = notification.userInfo
        let keyboardFram = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRect = keyboardFram.cgRectValue
        let keyboardHeight = keyboardRect.height*(-1)
        UIView.animate(withDuration: 0.3) { 
            self.view.transform = CGAffineTransform(translationX: 0, y: keyboardHeight)
        }
        
    }
    
    func backView(){
        UIView.animate(withDuration: 0.3) { 
            self.view.transform = CGAffineTransform.identity
        }
    }
}

extension LoginViewController:UITextFieldDelegate{
    // clsoe the keyboard when tapped the return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
