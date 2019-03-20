//
//  Helpers.swift
//  DiceKey
//
//  Created by Peter on 19/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import UIKit


func displayAlert(viewController: UIViewController, title: String, message: String) {
    print("displayAlert")
    
    let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
    viewController.present(alertcontroller, animated: true, completion: nil)
    
}
