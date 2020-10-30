//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Justin Ralph on 10/22/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.becomeFirstResponder()
        PFUser.registerSubclass()

        // Do any additional setup after loading the view.
    }
    @IBAction func onSignIn(_ sender: Any) {
        PFUser.logInWithUsername(inBackground:usernameField.text ?? "", password:passwordField.text ?? "") {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
            // Do stuff after successful login.
            self.performSegue(withIdentifier: "onLogin", sender: nil)
          } else {
            // The login failed. Check error to see why.
            print(error as Any)
            let alertController = UIAlertController(title: "Sign in failed", message: "Username/password do not match", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
          }
        }
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        user.signUpInBackground {
          (succeeded: Bool, error: Error?) -> Void in
          if let error = error {
            let errorString = error.localizedDescription
            print(errorString)
            // Show the errorString somewhere and let the user try again.
          } else {
            self.performSegue(withIdentifier: "onLogin", sender: nil)          }
        }
      }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
