//
//  HomeViewController.swift
//  Addventure
//
//  Created by Christian  on 4/24/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionview: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchPosts()
    }
    
    
    func fetchPosts(){
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String : AnyObject]
            self.posts.removeAll()
            self.following.removeAll()
            for (_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String]{
                            for (_,user) in followingUsers{
                                self.following.append(user)
                            }
                        }
                        self.following.append(FIRAuth.auth()!.currentUser!.uid)
                        print(self.following.count)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            
                            let postsSnap = snap.value as! [String : AnyObject]
                            
                            for (_,post) in postsSnap {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postdescription = post["postDescription"] as? String {
                                                
                                                posst.author = author
                                                posst.likes = likes
                                                posst.pathToImage = pathToImage
                                                posst.postID = postID
                                                posst.userID = userID
                                                posst.postDescription = postdescription
                                                
                                                
                                                self.posts.append(posst)
                                                
                                            }
                                        }
                                    }
                                    print(self.posts.count)
                                   self.collectionview.reloadData()
                                }
                            }
                        })
                    }  
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        cell.postID = self.posts[indexPath.row].postID
        cell.postDescription.text = self.posts[indexPath.row].postDescription
      
        
        return cell
    }
}
