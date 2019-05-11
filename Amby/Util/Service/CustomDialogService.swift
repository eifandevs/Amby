//
//  CustomDialogService.swift
//  Amby
//
//  Created by tenma on 2019/02/24.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

class CustomDialogService {
    static func presentTextFieldAlert(title: String, message: String, placeholder: String, action: @escaping ((String) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = placeholder
        }
        let saveAction = UIAlertAction(title: AppConst.APP.OK, style: UIAlertActionStyle.default, handler: { _ -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            action(firstTextField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: AppConst.APP.CANCEL, style: UIAlertActionStyle.default, handler: {(_: UIAlertAction!) -> Void in })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        Util.foregroundViewController().present(alertController, animated: true, completion: nil)
    }
}
