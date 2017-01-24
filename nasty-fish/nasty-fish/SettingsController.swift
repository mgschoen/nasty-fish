//
//  SettingsController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 07.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    
    // MARK: - @IBAction
    
    @IBAction func nickNameEditingChanged(_ sender: UITextField) {
        checkUserInput()
    }
    
    
    // MARK: - Getter
    
    var nickName: String {
        get {
            return nickNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    
    // MARK: - Default override
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Handle the text field’s user input through delegate callbacks.
        self.nickNameTextField.delegate = self
        
        // hide keyboard when user taps outside of textfield
        // https://stackoverflow.com/questions/27878732/swift-how-to-dismiss-number-keyboard-after-tapping-outside-of-the-textfield
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(NewTransactionController.didTapView))
        
        nickNameTextField.text = (UIApplication.shared.delegate as! AppDelegate).dataController!.fetchUserCustomName()
        
        checkUserInput()
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
    
    
    // MARK: - Helper
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func checkUserInput() {
        var canCancel = true
        var canSave = true
        
        // Check saved Nickname if nil disable cancel button
        if (UIApplication.shared.delegate as! AppDelegate).dataController!.fetchUserCustomName() == nil {
            canCancel = false
        }
        
        // Check nickNameTextField if isEmpty disable save button
        if (nickNameTextField.text?.isEmpty)! {
            canSave = false
        }
        
        cancelButton.isEnabled = canCancel
        saveButton.isEnabled = canSave
    }
}

extension SettingsController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Hide the keyboard.
        textField.resignFirstResponder()
    }
}

