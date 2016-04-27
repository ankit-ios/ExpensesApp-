//
//  SignupViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 06/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class controller handle all signup details or contain new user information.
 */

import UIKit
import RealmSwift

enum AddUserInfo {
    case NewUserInfo
    case ForgotPassword
}

class SignupViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameAlertLabel: UILabel!
    @IBOutlet weak var emailIdAlertLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordAlertLabel: UILabel!
    @IBOutlet weak var signupOutlet: UIButton!
    
    var userInfoObject: UserInformation?
    var addUserInfo = AddUserInfo.NewUserInfo
    
    // this button action is for signup for new user and will goto LogInViewController
    
    // MARK: - Signup Button
    
    @IBAction func signUp(sender: UIButton) {
        
        if passwordTextField.text != confirmPasswordTextField.text  {
            passwordAlertLabel.hidden = false
            return
        }
        
        if addUserInfo == .NewUserInfo {
            
            userInfoObject = UserInformation()
            userInfoObject?.userId = NSUUID().UUIDString
            userInfoObject?.userName = userNameTextField.text ?? ""
            userInfoObject?.emailId = emailTextField.text ?? ""
            userInfoObject?.password = passwordTextField.text ?? ""
            var categoryArray1: Category?
            
            let categoryArray = ["Hospital", "Fuel", "Transport", "Education", "Domestic"]
            
            if let userInfoObject = userInfoObject {
                try! uiRealm.write({() -> Void in
                    uiRealm.add(userInfoObject)
                })
                
                
                for categoryArrayName in categoryArray
                {
                    categoryArray1 = Category()
                    if let categoryArray1 = categoryArray1 {
                        try! uiRealm.write({() -> Void in
                            categoryArray1.categoryId = NSUUID().UUIDString
                            categoryArray1.categoryName = categoryArrayName
                            userInfoObject.categories.append(categoryArray1)
                            uiRealm.add(userInfoObject.categories)
                        })
                    }
                }
                
            }
            
        }
        else if addUserInfo == .ForgotPassword {
            
            let userInfo : Results<UserInformation>
            userInfo = uiRealm.objects(UserInformation)
            let userIndex = userInfo.indexOf("userName = %@ ",userNameTextField.text ?? "")
            if let userIndex = userIndex {
                userInfoObject = (uiRealm.objects(UserInformation))[userIndex]
                
                try! uiRealm.write({() -> Void in
                    if let userInfoObject = userInfoObject {
                        
                        userInfoObject.password = passwordTextField.text ?? ""
                        uiRealm.add(userInfoObject, update: true)
                    }
                })
                
                
            }
        }
        navigationController?.popViewControllerAnimated(true)
        
        //This button is for, if you are existing user then will go to LogInViewController
    }
    
    // MARK: - Login Button
    @IBAction func logInButtonAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(animated: Bool) {
        userNameAlertLabel.hidden = true
        emailIdAlertLabel.hidden = true
        passwordAlertLabel.hidden = true
        signupOutlet.enabled = false
        configureUI()
    }
    
    // MARK: - Configure UI
    func configureUI() {
        if addUserInfo == .ForgotPassword {
            navigationItem.title = "Change Password"
            userNameAlertLabel.text = "User does not Exits. Try correct User Name "
            emailIdAlertLabel.text = "email Id does not Exits. Try correct Email Id"
            passwordTextField.placeholder = "New Password"
            confirmPasswordTextField.placeholder = "Confirm New Password"
            signupOutlet.setTitle("Change Password", forState: .Normal)
        }
        
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
}


// MARK: - TextField Delegate
//handle some cases related to textfield for checking valid username and emailID

extension SignupViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(textField: UITextField){
        
        if addUserInfo == .NewUserInfo {
            if !userNameAlertLabel.hidden && userNameTextField.editing
            {
                userNameTextField.clearsOnBeginEditing = true
                userNameAlertLabel.hidden = true
            }
            else if !emailIdAlertLabel.hidden && emailTextField.editing
            {
                emailTextField.clearsOnBeginEditing = true
                emailIdAlertLabel.hidden = true
            }
            if !passwordAlertLabel.hidden
            {
                passwordAlertLabel.hidden = true
                passwordTextField.clearsOnBeginEditing = true
                confirmPasswordTextField.clearsOnBeginEditing = true
                passwordTextField.isFirstResponder()
                confirmPasswordTextField.isFirstResponder()
                
            }
        }
            
        else if addUserInfo == .ForgotPassword {
            if !userNameAlertLabel.hidden && userNameTextField.editing
            {
                userNameTextField.clearsOnBeginEditing = true
                userNameAlertLabel.hidden = true
            }
            else if !emailIdAlertLabel.hidden && emailTextField.editing
            {
                emailTextField.clearsOnBeginEditing = true
                emailIdAlertLabel.hidden = true
            }
            if !passwordAlertLabel.hidden
            {
                passwordAlertLabel.hidden = true
                passwordTextField.clearsOnBeginEditing = true
                confirmPasswordTextField.clearsOnBeginEditing = true
                passwordTextField.isFirstResponder()
                confirmPasswordTextField.isFirstResponder()
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        let userName = userNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        
        if addUserInfo == .NewUserInfo {
            guard uiRealm.objects(UserInformation).filter("userName = %@" , userName).count != 1  else {
                userNameAlertLabel.hidden = false
                return
            }
            userNameAlertLabel.hidden = true
            
            guard emailTextField.enabled && uiRealm.objects(UserInformation).filter("emailId = %@" , email).count != 1 else {
                emailIdAlertLabel.hidden = false
                return
            }
            
            guard validateEmail(emailTextField.text ?? "") == true else {
                emailIdAlertLabel.text = "Enter Valid Email Id"
                emailIdAlertLabel.hidden = false
                return
            }
            emailIdAlertLabel.hidden = true
            signupOutlet.enabled = true
        }
            
        else if addUserInfo == .ForgotPassword {
            
            guard uiRealm.objects(UserInformation).filter("userName = %@" , userName).count == 1  else {
                userNameAlertLabel.hidden = false
                return
            }
            userNameAlertLabel.hidden = true
            guard emailTextField.enabled && uiRealm.objects(UserInformation).filter("emailId = %@" , email).count == 1 else {
                emailIdAlertLabel.hidden = false
                return
            }
            emailIdAlertLabel.hidden = true
            signupOutlet.enabled = true
        }
    }
    
}





















