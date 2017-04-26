//
//  SignupViewController.swift
//  Addventure
//
//  Created by Christian  on 4/22/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bibliographyField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextbtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        let storage = FIRStorage.storage().reference(forURL: "gs://addventure-95da0.appspot.com")
        ref = FIRDatabase.database().reference()
        userStorage = storage.child("users")
    }
    
    @IBAction func selectImagePressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextbtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confirmPasswordField.text != "", bibliographyField.text != "" else {
            return
        }
        
        if passwordField.text == confirmPasswordField.text
        {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.put(data!, metadata: nil, completion: {
                        (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(err!.localizedDescription)
                            }
                            let trophies = 0
                            if let url = url {
                                let userInfo: [String: Any] = ["uid" : user.uid,
                                                               "full name" : self.nameField.text,
                                                               "urlToImage" : url.absoluteString,
                                                                "bibliography" : self.bibliographyField.text,
                                                                "trophies": trophies ]
                            self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView")
                                
                                self.present(vc, animated: true, completion: nil)
                            
                            }
                        })
                    })
                    uploadTask.resume()
                }
            })
        }
        else {
            print("Password Does Not Match")
        }
    }
    
    
}
