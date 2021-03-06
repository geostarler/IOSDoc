//
//  ViewController2.swift
//  DemoDCN
//
//  Created by Nguyen Tan Dung on 5/11/20.
//  Copyright © 2020 Nguyen Tan Dung. All rights reserved.
//

import UIKit

protocol ScreenDelegate {
    func changeLabel(text: String)
}

class ViewController2: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfNumber: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    var delegate: ScreenDelegate?
    var closure: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfNumber.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func checkValidTextField() -> Bool{
        if tfNumber.text?.count ?? 0 == 3 {
            lblError.isHidden = true
            return true
        } else {
            print("Error")
            lblError.isHidden = false
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfNumber {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    @IBAction func btnTest(_ sender: Any) {
//        delegate?.changeLabel(text: "abc")
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        if checkValidTextField() {
//            let screen1 = self.navigationController?.viewControllers[0] as! ViewController
//            screen1.lblNumber.text = "Number: \(String(tfNumber.text ?? ""))"
//            self.navigationController?.popToViewController(screen1, animated: true)
            //closure
            
            //Delegate
//            delegate?.changeLabel(text: tfNumber.text ?? "")
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["text": tfNumber.text ?? ""])
            self.navigationController?.popViewController(animated: true)
//            closure?(tfNumber.text ?? "")
        }
        
    
    }
    
    
    deinit {
        NSLog("Deinit VC2qưe")
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

let name = Notification.Name("didReceiveData")

