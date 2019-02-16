//
//  keyCreator.swift
//  DiceKey
//
//  Created by Peter on 16/02/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import Security
import UIKit

public func createPrivateKey(viewController: UIViewController, password: String, diceRolls: String) -> ([String:Any], Bool) {
    
    var success = Bool()
    let bytesCount = 32
    var randomNum = ""
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    
    if status == errSecSuccess {
        
        randomNum = randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
        randomNum = randomNum + diceRolls
        let sha256OfData = BTCSHA256(BTCDataFromHex(randomNum))
        
        if let mnemonic = BTCMnemonic.init(entropy: sha256OfData as Data!, password: password, wordListType: BTCMnemonicWordListType.english) {
            
            let words = mnemonic.words.description
            let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
            if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0") {
                keychain.key.isPublicKeyCompressed = true
                let addressHD = (keychain.key(at: 0).address.string)
                let privateKey = (keychain.key(at: 0).wif)!
                let publicKey = (keychain.key(at: 0).compressedPublicKey.hex())!
                let xpub = (keychain.extendedPublicKey)!
                keychain.key.clear()
                success = true
                
                return (["seed":recoveryPhrase, "privateKey":privateKey, "address":addressHD, "publicKey":publicKey, "xpub":xpub], success)
            }
            
            
        } else {
            
            return (["":""], false)
            
        }
        
        return (["":""], false)
    
    }
    
    return (["":""], false)
    
}
