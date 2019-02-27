//
//  CustomDialogService.swift
//  Amby
//
//  Created by tenma on 2019/02/24.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

class CustomDialogService {
    static func presentTextFieldAlert() {
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Second Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { _ -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (_: UIAlertAction!) -> Void in })
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter First Name"
        }

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        Util.foregroundViewController().present(alertController, animated: true, completion: nil)
    }
}
