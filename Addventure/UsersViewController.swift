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
    
    var users = [User]()

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
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            let users = snapshot.value as! [ String: AnyObject]
            self.users.removeAll()
            for (_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()?.currentUser!.uid{
                        let userToShow = User(snapshot: snapshot)
                        if let fullname = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullname
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.users.append(userToShow)
                        }
                    }
                }
            }
            self.TableView.reloadData()
        })
        ref.removeAllObservers()
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.userLabel.text = self.users[indexPath.row].fullName
        cell.userID = self.users[indexPath.row].userID
        cell.userImage.downloadImage(from: self.users[indexPath.row].imagePath!)
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
                    if value as! String == self.users[indexPath.row].userID {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.TableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
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
                    if value as! String == self.users[indexPath.row].userID {
                        self.TableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count ?? 0
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


