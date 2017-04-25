//
//  LoginViewController.swift
//  Addventure
//
//  Created by Christian  on 4/22/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else {return}
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            
            }
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView")
                self.present(vc, animated: true, completion: nil)
            }
        })
    }
    
}
