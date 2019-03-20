//
//  SettingsViewController.swift
//  DiceKey
//
//  Created by Peter on 10/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {

    @IBOutlet var settingsTable: UITableView!
    let userDefaults = UserDefaults.standard
    var watchOnly = Bool()
    var bip39Password = Bool()
    var bip44 = Bool()
    var bip84 = Bool()
    var electrumStandard = Bool()
    var electrumBip44 = Bool()
    var bitcoinCoreLegacy = Bool()
    var bitcoinCoreSegwit = Bool()
    var settingsArray = [[String:Any]]()
    let subtitles = ["xpub and addresses: m/44'/0'/0'/0, address prefix 1",
                     "xpub: m/84'/0', addresses: m/84'/0'/0'/0, address prefix bc1",
                     "xpub: m, addresses: m/0/0, address prefix 1",
                     "xpub: m/44'/0', addresses: m/44'/0'/0'/0, address prefix 1",
                     "xpub: m, addresses: m/0'/0'/0', address prefix 1",
                     "xpub: m, addresses: m/0'/0'/0', address prefix bc1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        tabBarController?.delegate = self
        settingsTable.tableFooterView = UIView(frame: .zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if userDefaults.object(forKey: "bip39Password") != nil {
            
            bip39Password = true
            
        } else {
            
            bip39Password = false
            
        }
        
        if userDefaults.object(forKey: "watchOnly") != nil {
            
            watchOnly = userDefaults.bool(forKey: "watchOnly")
            
        } else {
            
            watchOnly = true
            
        }
        
        if userDefaults.object(forKey: "BIP44") != nil {
            
            bip44 = userDefaults.bool(forKey: "BIP44")
            
        } else {
            
            bip44 = true
            
        }
        
        if userDefaults.object(forKey: "BIP84") != nil {
            
            bip84 = userDefaults.bool(forKey: "BIP84")
            
        } else {
            
            bip84 = false
            
        }
        
        if userDefaults.object(forKey: "Electrum Standard") != nil {
            
            electrumStandard = userDefaults.bool(forKey: "Electrum Standard")
            
        } else {
            
            electrumStandard = false
            
        }
        
        if userDefaults.object(forKey: "Electrum BIP44") != nil {
            
            electrumBip44 = userDefaults.bool(forKey: "Electrum BIP44")
            
        } else {
            
            electrumBip44 = false
            
        }
        
        if userDefaults.object(forKey: "Bitcoin Core Legacy") != nil {
            
            bitcoinCoreLegacy = userDefaults.bool(forKey: "Bitcoin Core Legacy")
            
        } else {
            
            bitcoinCoreLegacy = false
            
        }
        
        if userDefaults.object(forKey: "Bitcoin Core Segwit") != nil {
            
            bitcoinCoreSegwit = userDefaults.bool(forKey: "Bitcoin Core Segwit")
            
        } else {
            
            bitcoinCoreSegwit = false
            
        }
        
        
        settingsArray = [["BIP44":bip44,
                         "BIP84":bip84,
                         "Electrum Standard":electrumStandard,
                         "Electrum BIP44":electrumBip44,
                         "Bitcoin Core Legacy":bitcoinCoreLegacy,
                         "Bitcoin Core Segwit":bitcoinCoreSegwit],
                         ["BIP39 Password":bip39Password],
                         ["Watch-Only":watchOnly]]
        
        settingsTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let switchButton = cell.viewWithTag(2) as! UISwitch
        let title = cell.viewWithTag(3) as! UILabel
        let subtitle = cell.viewWithTag(1) as! UILabel
        let checkMark = cell.viewWithTag(4) as! UIImageView
        switchButton.alpha = 0
        checkMark.alpha = 0
        
        if indexPath.section == 0 {
            
            let dict = settingsArray[0]
            let key = Array(dict.keys)[indexPath.row]
            let value = Array(dict.values)[indexPath.row] as! Bool
            
            if value {
                
                cell.isSelected = true
                title.textColor = UIColor.white
                subtitle.textColor = UIColor.white
                checkMark.alpha = 1
                
            } else {
                
                cell.isSelected = false
                title.textColor = UIColor.darkGray
                subtitle.textColor = UIColor.darkGray
                
            }
            
            title.text = key
            subtitle.text = subtitles[indexPath.row]
            
        } else if indexPath.section == 1 {
            
            switchButton.alpha = 1
            let dictionary = settingsArray[indexPath.section]
            let key = Array(dictionary.keys)[indexPath.row]
            let value = Array(dictionary.values)[indexPath.row]
            switchButton.isOn = value as! Bool
            title.text = key
            subtitle.text = ""
            switchButton.addTarget(self, action: #selector(setBIP39Password), for: .touchUpInside)
            
        } else if indexPath.section == 2 {
            
            switchButton.alpha = 1
            let dictionary = settingsArray[indexPath.section]
            let key = Array(dictionary.keys)[indexPath.row]
            let value = Array(dictionary.values)[indexPath.row]
            switchButton.isOn = value as! Bool
            title.text = key
            subtitle.text = ""
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsArray[section].count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if indexPath.section == 0 {
            
            for row in 0 ..< tableView.numberOfRows(inSection: 0) {
                
                if let cell = self.settingsTable.cellForRow(at: IndexPath(row: row, section: 0)) {
                    
                    let title = cell.viewWithTag(3) as! UILabel
                    let subtitle = cell.viewWithTag(1) as! UILabel
                    let checkMark = cell.viewWithTag(4) as! UIImageView
                    
                    if indexPath.row == row && cell.isSelected {
                        
                        cell.isSelected = true
                        let key = title.text!
                        self.userDefaults.set(true, forKey: key)
                        title.textColor = UIColor.white
                        subtitle.textColor = UIColor.white
                        checkMark.alpha = 1
                        
                    } else {
                        
                        cell.isSelected = false
                        let key = title.text!
                        self.userDefaults.set(false, forKey: key)
                        title.textColor = UIColor.darkGray
                        subtitle.textColor = UIColor.darkGray
                        checkMark.alpha = 0
                        
                    }
                    
                }
                
            }
            
        }
                
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return settingsArray.count
        
    }
    
    @objc func setBIP39Password() {
        
        let cell = self.settingsTable.cellForRow(at: IndexPath(row: 0, section: 1))
        let switchButton = cell!.viewWithTag(2) as! UISwitch
        
        if !switchButton.isOn {
            
            self.userDefaults.removeObject(forKey: "bip39Password")
            
        } else {
            
            DispatchQueue.main.async {
                
                var firstPassword = String()
                var secondPassword = String()
                
                let alert = UIAlertController(title: "Dual Factor Password", message: "You have the option to create a BIP39 dual factor password to encrypt your recovery phrase. Only create a password if you are absolutely certain you will remember it. If you are worried you won't remember it just tap cancel and we will create your recovery phrase without a password.\n\nWe suggest writing the password down and saving it in multiple locations.", preferredStyle: .alert)
                
                alert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Add Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .destructive, handler: { (action) in
                    
                    firstPassword = alert.textFields![0].text!
                    
                    if firstPassword != "" {
                        
                        let confirmationAlert = UIAlertController(title: "Confirm Password", message: "Please input your password again to make sure there were no typos.", preferredStyle: .alert)
                        
                        confirmationAlert.addTextField { (textField1) in
                            
                            textField1.placeholder = "Confirm Password"
                            textField1.isSecureTextEntry = true
                            
                        }
                        
                        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (action) in
                            
                            secondPassword = confirmationAlert.textFields![0].text!
                            
                            if firstPassword == secondPassword {
                                
                                self.userDefaults.set(secondPassword, forKey: "bip39Password")
                                
                                displayAlert(viewController: self, title: "Success", message: "You added a password that will be used to encrypt your recovery phrase, write it down and save it in mulitple locations, if you lose it you will NOT be able to recover your Bitcoin.")
                                
                            } else {
                                
                                switchButton.isOn = false
                                self.userDefaults.removeObject(forKey: "bip39Password")
                                displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                                
                            }
                            
                        }))
                        
                        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                            
                            switchButton.isOn = false
                            self.userDefaults.removeObject(forKey: "bip39Password")
                            
                        }))
                        
                        self.present(confirmationAlert, animated: true, completion: nil)
                        
                    } else {
                        
                        switchButton.isOn = false
                        self.userDefaults.removeObject(forKey: "bip39Password")
                        
                        displayAlert(viewController: self, title: "Error", message: "You must input some text to set a BIP39 password")
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    switchButton.isOn = false
                    self.userDefaults.removeObject(forKey: "bip39Password")
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
}

extension SettingsViewController  {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MyTransition(viewControllers: tabBarController.viewControllers)
        
    }
    
}
