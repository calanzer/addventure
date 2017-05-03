//
//  KnowYourToolsViewController.swift
//  Addventure
//
//  Created by Christian  on 5/3/17.
//  Copyright © 2017 Chrstian Lanzer. All rights reserved.
//

import UIKit

class KnowYourToolsViewController: UIViewController {

    
    @IBAction func goToTutorial(_ sender: Any) {
        let url = URL(string: "https://quizlet.com/27228425/basic-kitchen-equipment-utensils-flash-cards/")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func addPost(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "addNew") as! UploadViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    

}
