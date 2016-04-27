//
//  LogInViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 06/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class controller handle login information and user authentication.
 */

import UIKit
import RealmSwift

class LogInViewController: UIViewController {
    
    var userInfoLists : Results<UserInformation>!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var forgotPasswordOutlets: UIButton!
    
    //this method is login for existing user otherwise gives warning message
    
    @IBAction func loginButton(sender: UIButton) {
        let userFilterObject = uiRealm.objects(UserInformation).filter("userName = %@ AND password = %@",userNameTextField.text ?? "" ,passwordTextField.text ?? "")
        
        if userFilterObject.count != 1 {
            alertLabel.hidden = false
            forgotPasswordOutlets.hidden = false
            updateUI()
        }
        else{
            if let expenseViewController = self.storyboard?.instantiateViewControllerWithIdentifier("expenseViewController") as? ExpenseAppMainViewController {
                let userInfo : Results<UserInformation>
                userInfo = uiRealm.objects(UserInformation)
                let userIndex = userInfo.indexOf("userName = %@ AND password = %@",userNameTextField.text ?? "" ,passwordTextField.text ?? "")
                if let userIndex = userIndex {
                    expenseViewController.userIndex = userIndex
                    expenseViewController.userInfo = (uiRealm.objects(UserInformation))[userIndex]
                }
                self.navigationController?.showViewController(expenseViewController, sender: nil)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoLists = uiRealm.objects(UserInformation)
    }
    
    override func viewWillAppear(animated: Bool) {
        alertLabel.hidden = true
        forgotPasswordOutlets.hidden = true
        updateUI()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let SignupViewControllerInstance = segue.destinationViewController as? SignupViewController
        if segue.identifier == "SignUpSegue" {
            SignupViewControllerInstance?.addUserInfo = .NewUserInfo
        }
        else if segue.identifier == "ForgotPasswordSegue" {
            SignupViewControllerInstance?.addUserInfo = .ForgotPassword
            
        }
        
        
    }
    // this method is for update UI when user put invalid data
    
    func updateUI () {
        userNameTextField.text = ""
        passwordTextField.text = ""
        passwordTextField.isFirstResponder()
        userNameTextField.isFirstResponder()
    }
}

//handle some cases related to UITextFieldDelegate

extension LogInViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(textField: UITextField)
    {
        alertLabel.hidden = true
    }
}
















