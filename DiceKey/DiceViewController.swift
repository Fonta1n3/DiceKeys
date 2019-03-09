//
//  DiceViewController.swift
//  DiceKey
//
//  Created by Peter on 11/02/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit
import BigInt
import AVFoundation
import SystemConfiguration
import EFQRCode

class DiceViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var keyDict = [[String:String]]()
    var password = ""
    var whatsThisTitle = "BIP39 Mnemonic"
    var whatsThisMessage = "\"A seed phrase, seed recovery phrase or backup seed phrase is a list of words which store all the information needed to recover a Bitcoin wallet. Wallet software will typically generate a seed phrase and instruct the user to write it down on paper. If the user's computer breaks or their hard drive becomes corrupted, they can download the same wallet software again and use the paper backup to get their bitcoins back.\" Source: https://en.bitcoin.it/wiki/Seed_phrase\n\nThis recovery phrase is used to create a keychain that allows you to create an infinite amount of deterministic private keys and addresses known as child keys. The derivitaion scheme DiceKey uses is BIP44 which is the industry standard, for more info visit https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki\n\nThe deriviation path we use is m/44'/0'/0'/0"
    let infoButton = UIButton()
    var nextIndex = 0
    var seedDict = [String:Any]()
    var recoveryPhraseQRView:UIImageView!
    var recoveryPhraseImage:UIImage!
    var imageView:UIView!
    var myField = UILabel()
    var mnemonicView: UITextView!
    var button = UIButton(type: .custom)
    var nextButton = UIButton(type: .custom)
    var diceButton = UIButton()
    var parseBitResult = BigInt()
    var words = String()
    var mnemonicLabel = UILabel()
    var recoveryPhrase = String()
    var diceArray = [UIButton]()
    var tappedIndex = Int()
    var randomBits = [String]()
    var percentageLabel = UILabel()
    var joinedBits = String()
    var bitCount:Int! = 0
    var clearButton = UIButton()
    let getNowButton = UIButton()
    let passwordButton = UIButton()
    let plusButton = UIButton()
    let minusButton = UIButton()
    var index = 0
    let brainButton = UIButton()
    let bitcoinCoreButton = UIButton()
    let indexLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
        tabBarController!.delegate = self
        showDice()
        percentageLabel.frame = CGRect(x: view.frame.maxX / 2 - 20, y: 50, width: 40, height: 40)
        percentageLabel.textColor = UIColor.black
        percentageLabel.backgroundColor = UIColor.white
        percentageLabel.layer.cornerRadius = 20
        percentageLabel.alpha = 0
        percentageLabel.text = "0%"
        percentageLabel.adjustsFontSizeToFitWidth = true
        percentageLabel.clipsToBounds = true
        addShadow(view: percentageLabel)
        percentageLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 15)
        percentageLabel.textAlignment = .center
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Library.sharedInstance.words = ""
        Library.sharedInstance.xpub = ""
        Library.sharedInstance.xprv = ""
        keyDict.removeAll()
        seedDict.removeAll()
        removePlusAndMinusButtons()
        percentageLabel.alpha = 0
        percentageLabel.text = "0%"
        mnemonicLabel.text = ""
        if recoveryPhraseQRView != nil {
            recoveryPhraseQRView.removeFromSuperview()
        }
        nextIndex = 0
        myField.text = ""
        infoButton.removeFromSuperview()
        percentageLabel.text = ""
        myField.removeFromSuperview()
        nextButton.removeFromSuperview()
        button.removeFromSuperview()
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        diceArray.removeAll()
        tappedIndex = 0
        showDice()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        
        let importedRecoveryPhrase = Library.sharedInstance.words
        let importedXpub = Library.sharedInstance.xpub
        let importedXprv = Library.sharedInstance.xprv
        
        if importedRecoveryPhrase != "" {
            
            //create key chain
            let dict = importKeyChainFromWords(viewController: self, password: password, words: importedRecoveryPhrase)
            self.removeHomeScreenButtons()
            
            for dice in self.diceArray {
                dice.removeFromSuperview()
            }
            self.diceArray.removeAll()
            self.tappedIndex = 0
            
            let success = dict["success"] as! Bool
            self.seedDict = dict["seedDict"] as! [String:String]
            self.keyDict = dict["keyArray"] as! [[String:String]]
            
            if success {
                
                self.words = self.seedDict["recoveryPhrase"] as! String
                self.button.removeFromSuperview()
                self.showRecoveryPhraseAndQRCode()
                
            } else {
                
                self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
            }
            
        } else if importedXpub != "" {
            
            let dict = importKeyChainFromXpub(viewController: self, xpub: importedXpub)
            
            self.removeHomeScreenButtons()
            
            for dice in self.diceArray {
                dice.removeFromSuperview()
            }
            self.diceArray.removeAll()
            self.tappedIndex = 0
            
            let success = dict["success"] as! Bool
            self.seedDict = dict["seedDict"] as! [String:String]
            self.keyDict = dict["keyArray"] as! [[String:String]]
            
            if success {
                
                self.words = self.seedDict["recoveryPhrase"] as! String
                self.button.removeFromSuperview()
                self.showRecoveryPhraseAndQRCode()
                
            } else {
                
                self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
            }
            
        } else if importedXprv != "" {
            
            let dict = importKeyChainFromXprv(viewController: self, xprv: importedXprv)
            
            self.removeHomeScreenButtons()
            
            for dice in self.diceArray {
                dice.removeFromSuperview()
            }
            self.diceArray.removeAll()
            self.tappedIndex = 0
            
            let success = dict["success"] as! Bool
            self.seedDict = dict["seedDict"] as! [String:String]
            self.keyDict = dict["keyArray"] as! [[String:String]]
            
            if success {
                
                self.words = self.seedDict["recoveryPhrase"] as! String
                self.button.removeFromSuperview()
                self.showRecoveryPhraseAndQRCode()
                
            } else {
                
                self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
            }
            
        }
        
    }
    
    func addGetNowButton() {
        
        DispatchQueue.main.async {
            
            self.getNowButton.removeFromSuperview()
            self.getNowButton.frame = CGRect(x: 5, y: 20, width: 30, height: 30)
            self.getNowButton.showsTouchWhenHighlighted = true
            self.getNowButton.setImage(UIImage(named: "ok@3x.png"), for: .normal)
            self.getNowButton.backgroundColor = UIColor.clear
            self.getNowButton.addTarget(self, action: #selector(self.getKeysNow), for: .touchUpInside)
            self.view.addSubview(self.getNowButton)
            
            self.passwordButton.removeFromSuperview()
            self.passwordButton.frame = CGRect(x: (self.view.frame.maxX / 3.75) - 15, y: 20, width: 30, height: 30)
            self.passwordButton.setImage(UIImage(named: "password@3x.png"), for: .normal)
            self.passwordButton.backgroundColor = UIColor.clear
            self.passwordButton.addTarget(self, action: #selector(self.setBIP39Password), for: .touchUpInside)
            self.view.addSubview(self.passwordButton)
            
            self.brainButton.removeFromSuperview()
            self.brainButton.frame = CGRect(x: (self.view.frame.maxX / 1.35) - 17.5, y: 18, width: 35, height: 35)
            self.brainButton.setImage(UIImage(named: "brain.png"), for: .normal)
            self.brainButton.backgroundColor = UIColor.clear
            self.brainButton.addTarget(self, action: #selector(self.getBrainWalletNow), for: .touchUpInside)
            self.view.addSubview(self.brainButton)
            
            self.bitcoinCoreButton.removeFromSuperview()
            self.bitcoinCoreButton.frame = CGRect(x: (self.view.frame.maxX / 2) - 15, y: 20, width: 30, height: 30)
            self.bitcoinCoreButton.setImage(UIImage(named: "bitcoinCore.png"), for: .normal)
            self.bitcoinCoreButton.backgroundColor = UIColor.clear
            self.bitcoinCoreButton.addTarget(self, action: #selector(self.getBitcoinCoreKey), for: .touchUpInside)
            self.view.addSubview(self.bitcoinCoreButton)
            
        }
        
   }
    
    @objc func getBitcoinCoreKey() {
        
        if !isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Attention!", message: "By tapping this button we will use any dice rolls you have made in conjunction with Apples cryptographically secure random number generator to create your keys. These keys are compatible with Bitcoin Core wallets. Using BIP32 derivation path m/0'/0' (keys are not hardened).", preferredStyle: UIAlertController.Style.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Get Keys Now", comment: ""), style: .default, handler: { (action) in
                    
                    self.removeHomeScreenButtons()
                    
                    for dice in self.diceArray {
                        dice.removeFromSuperview()
                    }
                    self.diceArray.removeAll()
                    self.tappedIndex = 0
                    
                    let dict = createBitcoinCoreKeyChain(viewController: self, password: self.password, diceRolls: self.joinedBits)
                    let success = dict["success"] as! Bool
                    self.seedDict = dict["seedDict"] as! [String:String]
                    self.keyDict = dict["keyArray"] as! [[String:String]]
                    
                    if success {
                        
                        self.words = self.seedDict["recoveryPhrase"] as! String
                        self.button.removeFromSuperview()
                        self.showRecoveryPhraseAndQRCode()
                        
                    } else {
                        
                        self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
                
                alert.popoverPresentationController?.sourceView = self.view
                self.present(alert, animated: true) {
                    print("option menu presented")
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(viewController: self, title: "Turn on airplane mode and wifi off to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the internet, secure keys are worth the effort.")
                
            }
            
        }
        
    }
    
    func removeHomeScreenButtons() {
        
        DispatchQueue.main.async {
            
            self.brainButton.removeFromSuperview()
            self.passwordButton.removeFromSuperview()
            self.getNowButton.removeFromSuperview()
            self.clearButton.removeFromSuperview()
            self.bitcoinCoreButton.removeFromSuperview()
            self.percentageLabel.removeFromSuperview()
            
        }
        
    }
    
    func addPlusAndMinusButtons() {
        
        DispatchQueue.main.async {
            
            self.plusButton.removeFromSuperview()
            self.minusButton.removeFromSuperview()
            
            self.plusButton.setImage(UIImage(named: "plus@3x.png"), for: .normal)
            self.minusButton.setImage(UIImage(named: "minus@3x.png"), for: .normal)
            
            self.plusButton.layer.cornerRadius = 15
            self.minusButton.layer.cornerRadius = 15
            
            self.plusButton.backgroundColor = UIColor.white
            self.minusButton.backgroundColor = UIColor.white
            
            self.addShadow(view: self.plusButton)
            self.addShadow(view: self.minusButton)
            
            self.plusButton.frame = CGRect(x: self.view.frame.maxX - 40, y: self.myField.frame.maxY - 10, width: 30, height: 30)
            self.minusButton.frame = CGRect(x: 10, y: self.myField.frame.maxY - 10, width: 30, height: 30)
            
            self.plusButton.addTarget(self, action: #selector(self.addToIndex), for: .touchUpInside)
            self.minusButton.addTarget(self, action: #selector(self.minusFromIndex), for: .touchUpInside)
            
            self.view.addSubview(self.plusButton)
            self.view.addSubview(self.minusButton)
            
            self.indexLabel.removeFromSuperview()
            self.indexLabel.frame = CGRect(x: self.view.center.x - 50, y: self.myField.frame.maxY - 10, width: 100, height: 30)
            self.indexLabel.textAlignment = .center
            self.indexLabel.textColor = UIColor.white
            self.indexLabel.font = UIFont.init(name: "HelveticaNeue", size: 20)
            self.addShadow(view: self.indexLabel)
            self.indexLabel.text = "# \(self.index)"
            self.view.addSubview(self.indexLabel)
            
        }
        
    }
    
    @objc func addToIndex() {
        print("addToIndex")
        
        if self.index < 19 {
            
            self.index = self.index + 1
            incrementViews()
            
            UIView.transition(with: self.indexLabel,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.indexLabel.text = "# \(self.index)" },
                              completion: nil)
            
        }
        
    }
    
    @objc func minusFromIndex() {
        
        if self.index > 0 {
            
            self.index = self.index - 1
            incrementViews()
            
            UIView.transition(with: self.indexLabel,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.indexLabel.text = "# \(self.index)" },
                              completion: nil)
            
        }
        
    }
    
    func removePlusAndMinusButtons() {
        
        DispatchQueue.main.async {
            
            self.plusButton.removeFromSuperview()
            self.minusButton.removeFromSuperview()
            self.indexLabel.removeFromSuperview()
            
        }
        
    }
    
    func incrementViews() {
        print("incrementViews")
        
        switch self.nextIndex {
            
        case 0:
            
            print("do nothing")
            
        case 1:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["privateKey"]!
                self.updateLabelsAndQrCode(header: "Private key:", key: text)
                self.whatsThisTitle = "WIF"
                self.whatsThisMessage = "\"Wallet Import Format (WIF, also known as Wallet Export Format) is a way of encoding a private ECDSA key so as to make it easier to copy.\" Source: https://en.bitcoin.it/wiki/Wallet_import_format\n\nThis is the first private key your seed will produce, you can type your seed in on this website to confirm it worked correclty and the first private key at the 0 index should be identical: https://iancoleman.io/bip39/\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS."
                
            }
            
        case 2:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["address"]!
                self.updateLabelsAndQrCode(header: "Address:", key: text)
                self.whatsThisTitle = "Bitcoin Address"
                self.whatsThisMessage = "\"A Bitcoin address, or simply address, is an identifier of 26-35 alphanumeric characters, beginning with the number 1 or 3, that represents a possible destination for a bitcoin payment. Addresses can be generated at no cost by any user of Bitcoin. For example, using Bitcoin Core, one can click \"New Address\" and be assigned an address. It is also possible to get a Bitcoin address using an account at an exchange or online wallet service.\" Source: https://en.bitcoin.it/wiki/Address\n\nThis address is the first address that is produced by your seed and can be found at the zero index on https://iancoleman.io/bip39/ it will be the address that is associated with the private key at the zero index.\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS"
                
            }
            
        case 3:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["publicKey"]!
                self.updateLabelsAndQrCode(header: "Public key:", key: text)
                self.whatsThisTitle = "Public Key"
                self.whatsThisMessage = "A public key is used to create your Bitcoin address, you can also use this public to create multi sig wallets which is why we provide it here. For example you could share your public key with others for the purpose of creating a multi sig wallet with other individuals or for yourself. Multi sig wallets are the most secure way to store bitcoin. This public key is again only associated with the first child key your seed will produce."
                
            }
            
        case 4:
            
            print("do nothing")
            
        default:
            
            break
            
        }
        
    }
    
    @objc func getBrainWalletNow() {
        
        if !isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Attention!", message: "By tapping this button we will create a brain wallet for you, the recovery phrase will be only 12 words so you can memorize it easily. For the brain wallet no dice rolls are needed. These wallets are BIP44 compatible with derivation path m/44'/0'/0'/0", preferredStyle: UIAlertController.Style.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Get Brain Wallet", comment: ""), style: .default, handler: { (action) in
                    
                    self.removeHomeScreenButtons()
                    
                    for dice in self.diceArray {
                        dice.removeFromSuperview()
                    }
                    self.diceArray.removeAll()
                    self.tappedIndex = 0
                    
                    let dict = createBrainWallet(viewController: self, password: self.password, diceRolls: self.joinedBits)
                    let success = dict["success"] as! Bool
                    self.seedDict = dict["seedDict"] as! [String:String]
                    self.keyDict = dict["keyArray"] as! [[String:String]]
                    
                    if success {
                        
                        self.words = self.seedDict["recoveryPhrase"] as! String
                        self.button.removeFromSuperview()
                        self.showRecoveryPhraseAndQRCode()
                        
                    } else {
                        
                        self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
                
                alert.popoverPresentationController?.sourceView = self.view
                self.present(alert, animated: true) {
                    print("option menu presented")
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(viewController: self, title: "Turn on airplane mode and wifi off to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the internet, secure keys are worth the effort.")
                
            }
            
        }
        
        
        
    }
    
    @objc func getKeysNow() {
        
        if !isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Attention!", message: "By tapping this button we will use any dice rolls you have made in conjunction with Apples cryptographically secure random number generator to create your keys. If you would only like to use your dice rolls then keep rolling more and DiceKeys will automatically generate the keys when you have rolled 256 bits worth of dice. These wallets are BIP44 compatible with derivation path m/44'/0'/0'/0", preferredStyle: UIAlertController.Style.actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Get Keys Now", comment: ""), style: .default, handler: { (action) in
                    
                    self.removeHomeScreenButtons()
                    
                    for dice in self.diceArray {
                        dice.removeFromSuperview()
                    }
                    self.diceArray.removeAll()
                    self.tappedIndex = 0
                    
                    let dict = createKeyChain(viewController: self, password: self.password, diceRolls: self.joinedBits)
                    let success = dict["success"] as! Bool
                    self.seedDict = dict["seedDict"] as! [String:String]
                    self.keyDict = dict["keyArray"] as! [[String:String]]
                        
                    if success {
                            
                        self.words = self.seedDict["recoveryPhrase"] as! String
                        self.button.removeFromSuperview()
                        self.showRecoveryPhraseAndQRCode()
                            
                    } else {
                            
                        self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
                        
                    }
                        
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
                
                alert.popoverPresentationController?.sourceView = self.view
                
                self.present(alert, animated: true) {
                    
                    print("option menu presented")
                    
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.displayAlert(viewController: self, title: "Turn on airplane mode and wifi off to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the internet, secure keys are worth the effort.")
                
            }
            
        }
        
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
        
        if self.view.frame.width < 1000 {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 3700)
        } else {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 6000)
        }
        
    }
    
    func addShadow(view: UIView) {
        print("addShadow")
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        view.layer.shadowRadius = 2.5
        view.layer.shadowOpacity = 0.8
        
    }
    
    
    func parseBinary(binary: String) -> BigInt? {
        print("parseBinary")
        
        var result:BigInt = 0
        
        for digit in binary {
            
            switch(digit) {
            case "0":result = result * 2
            case "1":result = result * 2 + 1
            default: return nil
                
            }
            
        }
        
        return result
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
    func displayAlert(viewController: UIViewController, title: String, message: String) {
        print("displayAlert")
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        viewController.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func isInternetAvailable() -> Bool {
        print("isInternetAvailable")
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
        
    }
    
    @objc func home() {
        print("home")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Warning!", message: "This will erase all data from the device and you will lose these keys forever, make sure you have triple checked that you saved them correctly before going back.", preferredStyle: UIAlertController.Style.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Go Back", comment: ""), style: .destructive, handler: { (action) in
                
                DispatchQueue.main.async {
                    
                    Library.sharedInstance.words = ""
                    Library.sharedInstance.xpub = ""
                    Library.sharedInstance.xprv = ""
                    self.keyDict.removeAll()
                    self.seedDict.removeAll()
                    self.removePlusAndMinusButtons()
                    self.percentageLabel.alpha = 0
                    self.percentageLabel.text = "0%"
                    self.mnemonicLabel.text = ""
                    self.password = ""
                    self.recoveryPhraseQRView.image = nil
                    self.nextIndex = 0
                    self.myField.text = ""
                    self.infoButton.removeFromSuperview()
                    self.percentageLabel.text = ""
                    self.myField.removeFromSuperview()
                    self.nextButton.removeFromSuperview()
                    self.button.removeFromSuperview()
                    self.showDice()
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in }))
            
            alert.popoverPresentationController?.sourceView = self.view
            self.present(alert, animated: true) {
                print("option menu presented")
            }
        }
    }
    
    @objc func showInfo() {
        print("showInfo")
        
        displayAlert(viewController: self, title: self.whatsThisTitle, message: self.whatsThisMessage)
        
    }
    
    func showRecoveryPhraseAndQRCode() {
        print("showPrivateKeyAndAddressQRCodes")
        
        let privateKey = self.keyDict[self.index]["privateKey"]!
        
        if words == "" && privateKey == ""  {
            
            recoveryPhraseImage = generateQrCode(key: self.keyDict[self.index]["address"]!)
            myField.text = self.keyDict[self.index]["address"]!
            mnemonicLabel.text = "Address:"
            nextIndex = 2
            addPlusAndMinusButtons()
            
        } else if privateKey != "" && words == "" {
            
            recoveryPhraseImage = generateQrCode(key: privateKey)
            myField.text = privateKey
            mnemonicLabel.text = "Private key:"
            nextIndex = 1
            addPlusAndMinusButtons()
            
        } else if words != "" {
            
            recoveryPhraseImage = generateQrCode(key: words)
            myField.text = words
            mnemonicLabel.text = "Recovery phrase:"
            
        }
        
        button.removeFromSuperview()
        button.frame = CGRect(x: 10, y: 24, width: 30, height: 30)
        button.showsTouchWhenHighlighted = true
        button.setImage(UIImage(named: "cancel@3x.png"), for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 15
        addShadow(view: button)
        button.addTarget(self, action: #selector(home), for: .touchUpInside)
        view.addSubview(button)
        
        recoveryPhraseQRView = UIImageView(image: recoveryPhraseImage!)
        recoveryPhraseQRView.frame = CGRect(x: view.center.x - ((view.frame.width - 70) / 2), y: view.center.y / 3, width: view.frame.width - 70, height: view.frame.width - 70)
        recoveryPhraseQRView.alpha = 0
        addShadow(view: recoveryPhraseQRView)
        recoveryPhraseQRView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        recoveryPhraseQRView.isUserInteractionEnabled = true
        view.addSubview(recoveryPhraseQRView)
        
        mnemonicLabel.frame = CGRect(x: view.center.x - ((view.frame.width - 70) / 2), y: recoveryPhraseQRView.frame.minY - 45, width: self.view.frame.width - 10, height: 40)
        mnemonicLabel.adjustsFontSizeToFitWidth = true
        mnemonicLabel.numberOfLines = 0
        addShadow(view: mnemonicLabel)
        mnemonicLabel.font = UIFont.init(name: "HelveticaNeue", size: 20)
        mnemonicLabel.textColor = UIColor.white
        mnemonicLabel.textAlignment = .left
        mnemonicLabel.alpha = 0
        view.addSubview(mnemonicLabel)
        
        infoButton.frame = CGRect(x: view.frame.maxX - 40, y: 24, width: 30, height: 30)
        infoButton.setImage(UIImage(named: "help@3x.png"), for: .normal)
        infoButton.backgroundColor = UIColor.white
        infoButton.layer.cornerRadius = 15
        addShadow(view: infoButton)
        infoButton.addTarget(self, action: #selector(self.showInfo), for: .touchUpInside)
        view.addSubview(infoButton)
        
        myField.frame = CGRect(x: 5, y: recoveryPhraseQRView.frame.maxY, width: view.frame.width - 10, height: 110)
        myField.backgroundColor = UIColor.clear
        addShadow(view: myField)
        myField.clipsToBounds = true
        myField.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shareText))
        myField.isUserInteractionEnabled = true
        myField.addGestureRecognizer(tap)
        myField.adjustsFontSizeToFitWidth = true
        myField.textColor = UIColor.white
        myField.numberOfLines = 0
        myField.textAlignment = .natural
        myField.font = UIFont.init(name: "HelveticaNeue", size: 18)
        myField.alpha = 0
        view.addSubview(myField)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.recoveryPhraseQRView.alpha = 1
            self.mnemonicLabel.alpha = 1
            self.myField.alpha = 1
            
        }, completion: { _ in
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.scrollView.setContentOffset(.zero, animated: false)
            self.addNextButton()
            
        })
        
    }
    
    func generateQrCode(key: String) -> UIImage? {
        print("generateQrCode")
        
        let cgImage = EFQRCode.generate(content: key,
                                        size: EFIntSize.init(width: 256, height: 256),
                                        backgroundColor: UIColor.white.cgColor,
                                        foregroundColor: UIColor.black.cgColor,
                                        watermark: nil,
                                        watermarkMode: EFWatermarkMode.scaleAspectFit,
                                        inputCorrectionLevel: EFInputCorrectionLevel.h,
                                        icon: nil,
                                        iconSize: nil,
                                        allowTransparent: true,
                                        pointShape: EFPointShape.circle,
                                        mode: EFQRCodeMode.none,
                                        binarizationThreshold: 0,
                                        magnification: EFIntSize.init(width: 50, height: 50),
                                        foregroundPointOffset: 0)
        let qrImage = UIImage(cgImage: cgImage!)
        
        return qrImage
        
    }
    
    func addNextButton() {
        print("addNextButton")
        
        DispatchQueue.main.async {
            self.nextButton = UIButton(frame: CGRect(x: self.view.center.x - 15, y: self.view.frame.maxY - 90, width: 30, height: 30))
            self.nextButton.showsTouchWhenHighlighted = true
            self.nextButton.setImage(UIImage(named: "refresh@3x.png"), for: .normal)
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.layer.cornerRadius = 15
            self.addShadow(view: self.nextButton)
            self.nextButton.addTarget(self, action: #selector(self.showNext), for: .touchUpInside)
            self.view.addSubview(self.nextButton)
        }
        
    }
    
    @objc func showNext() {
        print("next")
        
        let maxCount = 5
        
        if self.nextIndex < maxCount {
            
            self.nextIndex = self.nextIndex + 1
            
            if self.nextIndex == maxCount {
                
                self.nextIndex = 0
                
            }
            
        } else if self.nextIndex == maxCount {
            
            self.nextIndex = 0
            
        }
        
        switch self.nextIndex {
            
        case 0:
            
            DispatchQueue.main.async {
                
                let text = self.seedDict["recoveryPhrase"] as! String
                
                if text == "" {
                    
                    self.showNext()
                    
                } else {
                    
                    self.updateLabelsAndQrCode(header: "Recovery phrase:", key: text)
                    self.removePlusAndMinusButtons()
                    self.whatsThisTitle = "BIP39 Mnemonic"
                    self.whatsThisMessage = "\"A seed phrase, seed recovery phrase or backup seed phrase is a list of words which store all the information needed to recover a Bitcoin wallet. Wallet software will typically generate a seed phrase and instruct the user to write it down on paper. If the user's computer breaks or their hard drive becomes corrupted, they can download the same wallet software again and use the paper backup to get their bitcoins back.\" Source: https://en.bitcoin.it/wiki/Seed_phrase\n\nThis recovery phrase is used to create a keychain that allows you to create an infinite amount of deterministic private keys and addresses known as child keys. The derivitaion scheme DiceKey uses is BIP44 which is the industry standard, for more info visit https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki\n\nThe deriviation path we use is m/44'/0'/0'/0"
                    
                }
                
            }
            
        case 1:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["privateKey"]!
                
                if text == "" {
                    
                    self.showNext()
                    
                } else {
                    
                self.updateLabelsAndQrCode(header: "Private key:", key: text)
                self.addPlusAndMinusButtons()
                self.whatsThisTitle = "WIF"
                self.whatsThisMessage = "\"Wallet Import Format (WIF, also known as Wallet Export Format) is a way of encoding a private ECDSA key so as to make it easier to copy.\" Source: https://en.bitcoin.it/wiki/Wallet_import_format\n\nThis is the first private key your seed will produce, you can type your seed in on this website to confirm it worked correclty and the first private key at the 0 index should be identical: https://iancoleman.io/bip39/\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS."
                    
                }
                
            }
            
        case 2:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["address"]!
                self.addPlusAndMinusButtons()
                self.updateLabelsAndQrCode(header: "Address:", key: text)
                self.whatsThisTitle = "Bitcoin Address"
                self.whatsThisMessage = "\"A Bitcoin address, or simply address, is an identifier of 26-35 alphanumeric characters, beginning with the number 1 or 3, that represents a possible destination for a bitcoin payment. Addresses can be generated at no cost by any user of Bitcoin. For example, using Bitcoin Core, one can click \"New Address\" and be assigned an address. It is also possible to get a Bitcoin address using an account at an exchange or online wallet service.\" Source: https://en.bitcoin.it/wiki/Address\n\nThis address is the first address that is produced by your seed and can be found at the zero index on https://iancoleman.io/bip39/ it will be the address that is associated with the private key at the zero index.\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS"
                
            }
            
        case 3:
            
            DispatchQueue.main.async {
                
                let text = self.keyDict[self.index]["publicKey"]!
                self.updateLabelsAndQrCode(header: "Public key:", key: text)
                self.whatsThisTitle = "Public Key"
                self.whatsThisMessage = "A public key is used to create your Bitcoin address, you can also use this public to create multi sig wallets which is why we provide it here. For example you could share your public key with others for the purpose of creating a multi sig wallet with other individuals or for yourself. Multi sig wallets are the most secure way to store bitcoin. This public key is again only associated with the first child key your seed will produce."
                
            }
            
        case 4:
            
            DispatchQueue.main.async {
                
                let text = self.seedDict["xpub"] as! String
                self.updateLabelsAndQrCode(header: "XPUB:", key: text)
                self.removePlusAndMinusButtons()
                self.whatsThisTitle = "BIP32 Extended Public Key"
                self.whatsThisMessage = "This a an extended public key which you can use to create an infinite amount of addresses, its a great way to create a watch only wallet where you can easily create a new address to receive payments without storing your private keys. It is important to not show anyone else your xpub as that can increase their chances at getting access to your Bitcoin."
                
            }
            
        default:
            
            break
            
        }
        
    }
    
    func updateLabelsAndQrCode(header: String, key: String) {
        print("updateLabelsAndQrCode")
        
        DispatchQueue.main.async {
            
            self.recoveryPhraseImage = self.generateQrCode(key: key)
            
            UIView.transition(with: self.recoveryPhraseQRView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.recoveryPhraseQRView.image = self.recoveryPhraseImage },
                              completion: nil)
            
            UIView.transition(with: self.mnemonicLabel,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.mnemonicLabel.text = header },
                              completion: nil)
            
            UIView.transition(with: self.myField,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.myField.text = key },
                              completion: nil)
            
            UIImpactFeedbackGenerator().impactOccurred()
            
        }
        
    }
    
    func addPercentageCompleteLabel() {
        print("addPercentageCompleteLabel")
        
        DispatchQueue.main.async {
            let percentage:Double = (Double(self.bitCount) / 256.0) * 100.0
            self.percentageLabel.text = "\(Int(percentage))%"
        }
    }
    
    func addClearButton() {
        print("addClearButton")
        
        DispatchQueue.main.async {
            self.clearButton.removeFromSuperview()
            self.clearButton.frame = CGRect(x: self.view.frame.maxX - 40, y: 20, width: 30, height: 30)
            self.clearButton.setImage(#imageLiteral(resourceName: "clear.png"), for: .normal)
            self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
            self.view.addSubview(self.clearButton)
        }
        
    }
    
    @objc func tapClearDice() {
        print("tapClearDice")
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if self.tappedIndex > 0 {
            self.clearDice(sender: self.diceArray[self.tappedIndex - 1])
        }
        
    }
    
    func clearDice(sender: UIButton) {
        print("clearDice")
        
        DispatchQueue.main.async {
            self.tappedIndex = self.tappedIndex - 1
            sender.setTitle("0", for: .normal)
            sender.setImage(#imageLiteral(resourceName: "blackDice.png"), for: .normal)
            self.creatBitKey()
        }
    }
    
    func creatBitKey() {
        print("creatBitKey")
        
        for dice in self.diceArray {
            
            let diceNumber = Int((dice.titleLabel?.text)!)!
            
            if diceNumber != 0 {
                
                if dice.tag < self.tappedIndex {
                    
                    switch diceNumber {
                        
                    case 1:
                        self.randomBits.append("00")
                    case 2:
                        self.randomBits.append("01")
                    case 3:
                        self.randomBits.append("10")
                    case 4:
                        self.randomBits.append("11")
                    case 5:
                        self.randomBits.append("0")
                    case 6:
                        self.randomBits.append("1")
                    default: break
                        
                    }
                    
                    self.joinedBits = randomBits.joined()
                    self.bitCount = 0
                    
                    for _ in self.joinedBits {
                        self.bitCount = bitCount + 1
                    }
                    
                    self.addPercentageCompleteLabel()
                    
                    if self.bitCount > 255 {
                        
                        DispatchQueue.main.async {
                            
                            if self.bitCount == 257 {
                                self.joinedBits.removeLast()
                            }
                            
                            self.parseBitResult = self.parseBinary(binary: self.joinedBits)!
                            
                            var count = 0
                            for _ in self.joinedBits {
                                count = count + 1
                            }
                            
                            self.percentageLabel.removeFromSuperview()
                            self.clearButton.removeFromSuperview()
                            
                            for dice in self.diceArray {
                                dice.removeFromSuperview()
                            }
                            self.diceArray.removeAll()
                            self.tappedIndex = 0
                            
                            let dict = createKeyChain(viewController: self, password: self.password, diceRolls: self.joinedBits)
                            let success = dict["success"] as! Bool
                            self.seedDict = dict["seedDict"] as! [String:String]
                            self.keyDict = dict["keyArray"] as! [[String:String]]
                            
                            if success {
                                
                                self.words = self.seedDict["recoveryPhrase"] as! String
                                self.button.removeFromSuperview()
                                self.showRecoveryPhraseAndQRCode()
                                
                            } else {
                                
                                self.displayAlert(viewController: self, title: "Error", message: "We apologize, that really shouldn't have happened... Please email us at BitSenseApp@gmail.com and let us know what happened so we can fix it.")
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        self.randomBits.removeAll()
        
    }
    
    @objc func tapDice(sender: UIButton!) {
        
        percentageLabel.alpha = 1
        
        let diceNumber = Int((sender.titleLabel?.text)!)!
        sender.titleLabel?.textColor = UIColor.clear
        sender.titleLabel?.backgroundColor = UIColor.clear
        sender.titleLabel?.alpha = 0
        
        func addDiceValue() {
            
            switch diceNumber {
                
            case 0:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice1.png"), for: .normal)
                }
            case 1:
                DispatchQueue.main.async {
                    sender.setTitle("2", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice2.png"), for: .normal)
                }
            case 2:
                DispatchQueue.main.async {
                    sender.setTitle("3", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice3.png"), for: .normal)
                }
            case 3:
                DispatchQueue.main.async {
                    sender.setTitle("4", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice4.png"), for: .normal)
                }
            case 4:
                DispatchQueue.main.async {
                    sender.setTitle("5", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice5.png"), for: .normal)
                }
            case 5:
                DispatchQueue.main.async {
                    sender.setTitle("6", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice6.png"), for: .normal)
                }
            case 6:
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.setImage(#imageLiteral(resourceName: "dice1.png"), for: .normal)
                }
                
            default:
                break
            }
            
        }
        
        if !isInternetAvailable() {
            
            percentageLabel.removeFromSuperview()
            view.addSubview(percentageLabel)
        
            if sender.tag == 1 && diceNumber == 0 {
            
                self.tappedIndex = sender.tag
                addDiceValue()
            
            } else if sender.tag == self.tappedIndex + 1 {
            
                self.tappedIndex = sender.tag
                addDiceValue()
                creatBitKey()
            
            } else if sender.tag == self.tappedIndex {
            
                addDiceValue()
            
            } else {
            
                DispatchQueue.main.async {
                
                    let alert = UIAlertController(title: NSLocalizedString("You must input dice values in order.", comment: ""), message: "In order for the key to be cryptographically secure you must input the actual values of your dice as they appear to you from left to right, in order row by row.\n\nStart with the top left dice and work your way to the right being very careful to ensure you input the dice values correctly.", preferredStyle: UIAlertController.Style.alert)
                
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, got it", comment: ""), style: .default, handler: { (action) in }))
                
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Why?", comment: ""), style: .default, handler: { (action) in
                    
                        self.displayAlert(viewController: self, title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on cryptographic secure randomness. We also do this to make it impossible for you to accidentally tap and change a value of a dice you have already input. Secure keys are worth the effort!")
                    
                    }))
                
                    self.present(alert, animated: true, completion: nil)
                
                }
            
            }
        
        } else {
         
            DispatchQueue.main.async {
            
                self.displayAlert(viewController: self, title: "Turn on airplane mode and wifi off to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the internet, secure keys are worth the effort.")
            
            }
            
        }
        
    }
    
    func showDice() {
        print("showDice")
        
        addGetNowButton()
        addClearButton()
        var xvalue:Int!
        let screenWidth = self.view.frame.width
        let width = Int(screenWidth / 6)
        let height = width
        let xSpacing = width / 6
        xvalue = xSpacing
        var yvalue = 80
        var zero = 0
        view.addSubview(scrollView)
        
        for _ in 0..<40 {
            for _ in 0..<5 {
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: width, height: height))
                self.diceButton.setImage(#imageLiteral(resourceName: "blackDice.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.backgroundColor = .clear
                self.diceButton.setTitle("\(0)", for: .normal)
                self.diceButton.titleLabel?.alpha = 0
                self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                self.diceArray.append(self.diceButton)
                self.scrollView.addSubview(self.diceButton)
                xvalue = xvalue + width + xSpacing
            }
            xvalue = xSpacing
            if screenWidth < 1000 {
                yvalue = yvalue + 90
            } else {
                yvalue = yvalue + 180
            }
            
        }
        
    }
    
    @objc func setBIP39Password() {
        
        DispatchQueue.main.async {
            var firstPassword = String()
            var secondPassword = String()
            
            let alert = UIAlertController(title: "Dual Factor Password", message: "You have the option to create a BIP39 dual factor password to encrypt your recovery phrase. Only create a password if you are absolutely certain you will remember it. If you are worried you won't remember it just tap cancel and we will create your recovery phrase without a password.\n\nWE DO NOT SAVE THE PASSWORD, once your recovery phrase is created the device WILL ERASE ALL DATA, there is no lost password button. We suggest writing the password down and saving it in multiple locations.", preferredStyle: .alert)
            
            alert.addTextField { (textField1) in
                
                textField1.placeholder = "Add Password"
                textField1.isSecureTextEntry = true
                
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .destructive, handler: { (action) in
                
                firstPassword = alert.textFields![0].text!
                
                let confirmationAlert = UIAlertController(title: "Confirm Password", message: "Please input your password again to make sure there were no typos.", preferredStyle: .alert)
                
                confirmationAlert.addTextField { (textField1) in
                    
                    textField1.placeholder = "Confirm Password"
                    textField1.isSecureTextEntry = true
                    
                }
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (action) in
                    
                    secondPassword = confirmationAlert.textFields![0].text!
                    
                    if firstPassword == secondPassword {
                        
                        self.password = secondPassword
                        self.displayAlert(viewController: self, title: "Success", message: "You have succesfully added a password that will be used to encrpyt the recovery you will now make by rolling dice and inputing the values into the app, please ensure you don't forget the password as you will need it along with your recovery phrase to recover your Bitcoin.")
                        
                    } else {
                        
                        self.displayAlert(viewController: self, title: "Error", message: "Passwords did not match please start over.")
                        
                    }
                    
                }))
                
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(confirmationAlert, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func shareQRCode() {
        
        DispatchQueue.main.async {
                
                let activityController = UIActivityViewController(activityItems: [self.recoveryPhraseQRView.image as Any], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            
        }
        
    }
    
    @objc func shareText() {
        
        DispatchQueue.main.async {
            
            let textToShare = [self.myField.text]
            let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.myField.alpha = 0
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.myField.alpha = 1
                    
                })
                
                self.present(activityViewController, animated: true, completion: nil)
                
            })
            
            
            
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        print("getDocumentsDirectory")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        
    }
    
    @objc private func imageTapped(_ recognizer: UITapGestureRecognizer) {
        print("image tapped")
        
        shareQRCode()
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.recoveryPhraseQRView.alpha = 0
                
            }) { _ in
                
                UIView.animate(withDuration: 0.2) {
                    self.recoveryPhraseQRView.alpha = 1
                }
                
            }
            
        }
        
    }

}

extension DiceViewController  {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MyTransition(viewControllers: tabBarController.viewControllers)
        
    }
    
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
    
}
