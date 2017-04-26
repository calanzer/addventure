//
//  User.swift
//  Addventure
//
//  Created by Christian  on 4/24/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class User: NSObject {

    var userID: String!
    var fullName: String!
    var imagePath: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var bibligraphy: String?
    var trophies: Double?
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        userID = (snapshot.value! as! NSDictionary)["uid"] as! String
        fullName = (snapshot.value! as! NSDictionary)["full name"] as! String
        imagePath = (snapshot.value! as! NSDictionary)["urlToImage"] as! String
        bibligraphy = (snapshot.value! as! NSDictionary)["bibliography"] as! String
        trophies = (snapshot.value! as! NSDictionary) ["trophies"] as! Double
        
    }
    
}
