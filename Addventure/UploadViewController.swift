//
//  UploadViewController.swift
//  Addventure
//
//  Created by Christian  on 4/24/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var postdescriptionField: UITextView!
    
    
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
           picker.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
         view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func selectPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
       
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            selectBtn.isHidden = true
            postBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func postPressed(_ sender: Any) {
        
        AppDelegate.instance().showActivityIndicator()
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "gs://addventure-95da0.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let uploadTask = imageRef.put(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                AppDelegate.instance().dismissActivityIndicatos()
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["userID" : uid,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : FIRAuth.auth()!.currentUser!.displayName!,
                                "postID" : key,
                                "postDescription" : self.postdescriptionField.text!] as [String : Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicatos()
                    
                    self.tabBarController?.selectedIndex = 0
                }
            })
            
        }
        
        uploadTask.resume()
        
    }
}
