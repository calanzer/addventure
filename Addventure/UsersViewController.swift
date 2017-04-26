//
//  Users.swift
//  Addventure
//
//  Created by Christian  on 4/24/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UsersViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    
    var userArray = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveUsers()
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        
        return FIRStorage.storage()
    }
    
    
    func retrieveUsers () {
        dataBaseRef.child("users").observe(.value, with: { (snapshot) in
            var results = [User]()
            
            for user in snapshot.children {
                
                let user = User(snapshot: user as! FIRDataSnapshot)
                
                if user.userID != FIRAuth.auth()!.currentUser!.uid {
                    results.append(user)
                }
                
            }
            
            self.userArray = results.sorted(by: { (u1, u2) -> Bool in
                u1.fullName < u2.fullName
            })
           self.TableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.userLabel.text = userArray[indexPath.row].fullName
        cell.userID = userArray[indexPath.row].userID
        cell.userImage.downloadImage(from: userArray[indexPath.row].imagePath!)
          checkFollowing(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.userArray[indexPath.row].userID {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.userArray[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.TableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.userArray[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.userArray[indexPath.row].userID).updateChildValues(followers)
                
                self.TableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.userArray[indexPath.row].userID {
                        self.TableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count ?? 0
    }

}

extension UIImageView {
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
    
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
            self.image = UIImage(data: data!)
    
            }
        }
    task.resume()
    }
}


