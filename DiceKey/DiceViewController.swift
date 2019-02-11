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

class DiceViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var password = ""
    var whatsThisTitle = "BIP39 Mnemonic"
    var whatsThisMessage = "\"A seed phrase, seed recovery phrase or backup seed phrase is a list of words which store all the information needed to recover a Bitcoin wallet. Wallet software will typically generate a seed phrase and instruct the user to write it down on paper. If the user's computer breaks or their hard drive becomes corrupted, they can download the same wallet software again and use the paper backup to get their bitcoins back.\" Source: https://en.bitcoin.it/wiki/Seed_phrase\n\nThis recovery phrase is used to create a keychain that allows you to create an infinite amount of deterministic private keys and addresses known as child keys. The derivitaion scheme DiceKey uses is BIP44 which is the industry standard, for more info visit https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki/n/nThe deriviation path we use is m/44'/0'/0'/0"
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
    var words = ""
    var mnemonicLabel = UILabel()
    var recoveryPhrase = String()
    var diceArray = [UIButton]()
    var tappedIndex = Int()
    var randomBits = [String]()
    var percentageLabel = UILabel()
    var joinedBits = String()
    var bitCount:Int! = 0
    var clearButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
        showDice()
        percentageLabel.frame = CGRect(x: view.frame.maxX / 2 - 50, y: view.frame.minY + 10, width: 100, height: 50)
        percentageLabel.textColor = UIColor.white
        percentageLabel.backgroundColor = UIColor.clear
        addShadow(view: percentageLabel)
        percentageLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        percentageLabel.textAlignment = .center
        
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
                    self.mnemonicLabel.text = ""
                    self.password = ""
                    self.recoveryPhraseQRView.image = nil
                    self.seedDict.removeAll()
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
        
        self.button.removeFromSuperview()
        self.button = UIButton(frame: CGRect(x: 5, y: self.view.frame.maxY - 60, width: 90, height: 55))
        self.button.showsTouchWhenHighlighted = true
        self.button.setTitle("Done", for: .normal)
        self.button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        self.button.backgroundColor = UIColor.clear
        addShadow(view: self.button)
        self.button.setTitleColor(UIColor.white, for: .normal)
        self.button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        self.mnemonicLabel.frame = CGRect(x: 5, y: 25, width: self.view.frame.width - 10, height: 60)
        self.mnemonicLabel.text = "Your recovery phrase/seed:"
        self.mnemonicLabel.adjustsFontSizeToFitWidth = true
        self.mnemonicLabel.numberOfLines = 0
        self.mnemonicLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 30)
        self.mnemonicLabel.textColor = UIColor.white
        self.mnemonicLabel.textAlignment = .center
        self.mnemonicLabel.alpha = 0
        self.view.addSubview(self.mnemonicLabel)
        
        self.recoveryPhraseImage = self.generateQrCode(key: self.words)
        self.recoveryPhraseQRView = UIImageView(image: self.recoveryPhraseImage!)
        self.recoveryPhraseQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 70) / 2), y: self.view.center.y / 2.5, width: self.view.frame.width - 70, height: self.view.frame.width - 70)
        self.recoveryPhraseQRView.alpha = 0
        self.view.addSubview(self.recoveryPhraseQRView)
        
        
        infoButton.frame = CGRect(x: 50, y: self.recoveryPhraseQRView.frame.minY - 25, width: self.view.frame.width - 100, height: 20)
        infoButton.setTitle("What's this?", for: .normal)
        infoButton.titleLabel?.textAlignment = .center
        infoButton.setTitleColor(UIColor.white, for: .normal)
        infoButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        infoButton.addTarget(self, action: #selector(self.showInfo), for: .touchUpInside)
        infoButton.backgroundColor = UIColor.clear
        self.view.addSubview(infoButton)
        
        myField.frame = CGRect(x: 5, y: recoveryPhraseQRView.frame.maxY + 5, width: self.view.frame.width - 20, height: 110)
        myField.text = self.words
        myField.backgroundColor = UIColor.black
        myField.clipsToBounds = true
        myField.layer.cornerRadius = 10
        myField.adjustsFontSizeToFitWidth = true
        myField.textColor = UIColor.green
        myField.numberOfLines = 0
        myField.textAlignment = .center
        myField.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        myField.alpha = 0
        self.view.addSubview(self.myField)
        
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
        
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            let qrImage = UIImage(cgImage: cgImage!)
            return qrImage
        }
        
        return nil
        
    }
    
    func addNextButton() {
        print("addNextButton")
        
        DispatchQueue.main.async {
            self.nextButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 90, y: self.view.frame.maxY - 60, width: 80, height: 55))
            self.nextButton.showsTouchWhenHighlighted = true
            self.nextButton.setTitle("Next", for: .normal)
            self.nextButton.setTitleColor(UIColor.white, for: .normal)
            self.nextButton.backgroundColor = UIColor.clear
            self.addShadow(view: self.nextButton)
            self.nextButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.nextButton.addTarget(self, action: #selector(self.showNext), for: .touchUpInside)
            self.view.addSubview(self.nextButton)
        }
        
    }
    
    @objc func showNext() {
        print("next")
        
        let maxCount = self.seedDict.count
        
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
                let text = self.seedDict["seed"] as! String
                self.updateLabelsAndQrCode(header: "Your recovery phrase/seed:", key: text)
                self.whatsThisTitle = "BIP39 Mnemonic"
                self.whatsThisMessage = "\"A seed phrase, seed recovery phrase or backup seed phrase is a list of words which store all the information needed to recover a Bitcoin wallet. Wallet software will typically generate a seed phrase and instruct the user to write it down on paper. If the user's computer breaks or their hard drive becomes corrupted, they can download the same wallet software again and use the paper backup to get their bitcoins back.\" Source: https://en.bitcoin.it/wiki/Seed_phrase\n\nThis recovery phrase is used to create a keychain that allows you to create an infinite amount of deterministic private keys and addresses known as child keys. The derivitaion scheme DiceKey uses is BIP44 which is the industry standard, for more info visit https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki/n/nThe deriviation path we use is m/44'/0'/0'/0"
            }
        case 1:
            DispatchQueue.main.async {
                let text = self.seedDict["privateKey"] as! String
                self.updateLabelsAndQrCode(header: "Your private key WIF at index 0:", key: text)
                self.whatsThisTitle = "WIF"
                self.whatsThisMessage = "\"Wallet Import Format (WIF, also known as Wallet Export Format) is a way of encoding a private ECDSA key so as to make it easier to copy.\" Source: https://en.bitcoin.it/wiki/Wallet_import_format\n\nThis is the first private key your seed will produce, you can type your seed in on this website to confirm it worked correclty and the first private key at the 0 index should be identical: https://iancoleman.io/bip39/\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS."
            }
        case 2:
            DispatchQueue.main.async {
                let text = self.seedDict["address"] as! String
                self.updateLabelsAndQrCode(header: "Your address at index 0:", key: text)
                self.whatsThisTitle = "Bitcoin Address"
                self.whatsThisMessage = "\"A Bitcoin address, or simply address, is an identifier of 26-35 alphanumeric characters, beginning with the number 1 or 3, that represents a possible destination for a bitcoin payment. Addresses can be generated at no cost by any user of Bitcoin. For example, using Bitcoin Core, one can click \"New Address\" and be assigned an address. It is also possible to get a Bitcoin address using an account at an exchange or online wallet service.\" Source: https://en.bitcoin.it/wiki/Address\n\nThis address is the first address that is produced by your seed and can be found at the zero index on https://iancoleman.io/bip39/ it will be the address that is associated with the private key at the zero index.\n\nONLY TYPE TEST SEEDS INTO THE WEBSITE AS IT COULD COMPROMISE YOUR FUNDS"
            }
        case 3:
            DispatchQueue.main.async {
                let text = self.seedDict["publicKey"] as! String
                self.updateLabelsAndQrCode(header: "Your compressed public key at index 0:", key: text)
                self.whatsThisTitle = "Public Key"
                self.whatsThisMessage = "A public key is used to create your Bitcoin address, you can also use this public to create multi sig wallets which is why we provide it here. For example you could share your public key with others for the purpose of creating a multi sig wallet with other individuals or for yourself. Multi sig wallets are the most secure way to store bitcoin. This public key is again only associated with the first child key your seed will produce."
            }
        case 4:
            DispatchQueue.main.async {
                let text = self.seedDict["xpub"] as! String
                self.updateLabelsAndQrCode(header: "Your xpub:", key: text)
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
            self.mnemonicLabel.text = header
            self.recoveryPhraseImage = self.generateQrCode(key: key)
            self.recoveryPhraseQRView.image = self.recoveryPhraseImage
            self.myField.text = key
        }
    }
    
    func getDocumentsDirectory() -> URL {
        print("getDocumentsDirectory")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
            self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 60, y: 20, width: 55 , height: 55))
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
                            
                            self.seedDict = diceKey(viewController: self, userRandomness: self.parseBitResult, password: self.password).0
                            let success = diceKey(viewController: self, userRandomness: self.parseBitResult, password: self.password).1
                            
                            print("array = \(self.seedDict)")
                            
                            if success {
                                
                                self.words = self.seedDict["seed"] as! String
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
        
        let diceNumber = Int((sender.titleLabel?.text)!)!
        sender.titleLabel?.textColor = UIColor.clear
        sender.titleLabel?.backgroundColor = UIColor.clear
        
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
        
        //if isInternetAvailable() == false {
        
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
                    
                    self.displayAlert(viewController: self, title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on true cryptographic secure randomness. We also do this to make it impossible for you to accidentally tap and change a value of a dice you have already input. Secure keys ARE WORTH the effort!")
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        /*} else {
         
         DispatchQueue.main.async {
         self.displayAlert(viewController: self, title: "Turn on airplane mode and wifi off to create private keys securely.", message: "The idea is to never let your Bitcoin private key touch the interent, secure keys are worth the effort.")
         }
         }*/
    }
    
    func showDice() {
        print("showDice")
        
        self.addClearButton()
        var xvalue:Int!
        let screenWidth = self.view.frame.width
        print("screenWidth = \(screenWidth)")
        let width = Int(screenWidth / 6)
        let height = width
        let xSpacing = width / 6
        xvalue = xSpacing
        var yvalue = 80
        var zero = 0
        self.view.addSubview(self.scrollView)
        view.addSubview(percentageLabel)
        
        for _ in 0..<40 {
            for _ in 0..<5 {
                zero = zero + 1
                self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: width, height: height))
                self.diceButton.setImage(#imageLiteral(resourceName: "blackDice.png"), for: .normal)
                self.diceButton.tag = zero
                self.diceButton.showsTouchWhenHighlighted = true
                self.diceButton.backgroundColor = .clear
                self.diceButton.setTitle("\(0)", for: .normal)
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
        
        setBIP39Password()
    }
    
    func setBIP39Password() {
        
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

}
