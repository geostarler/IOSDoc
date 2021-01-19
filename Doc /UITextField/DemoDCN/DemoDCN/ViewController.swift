//
//  ViewController.swift
//  DemoDCN
//
//  Created by Nguyen Tan Dung on 5/11/20.
//  Copyright © 2020 Nguyen Tan Dung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var btnChangeScreen: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeText), name: name, object: nil)
    }

    @objc private func changeText(_ notification: Notification) {
        let data = notification.userInfo
        if data != nil {
            lblNumber.text = data!["text"] as? String
        }
    }
    
    deinit {
        NSLog("denit")
        NotificationCenter.default.removeObserver(self)
    }
//    override func viewD(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: name, object: nil)
//    }
    @IBAction func btnChangeScreenClicked(_ sender: Any) {
        let screen2 = self.storyboard?.instantiateViewController(withIdentifier: "ViewController2") as! ViewController2
//        screen2.delegate = self
//        screen2.closure = { (text) in
//            self.lblNumber.text = text
//        }
        
        self.navigationController?.pushViewController(screen2, animated: true)
    }
}

//extension ViewController: ScreenDelegate {
//    func changeLabel(text: String) {
//        lblNumber.text = "Number: \(text)"
//    }
//}
