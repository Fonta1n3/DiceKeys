//
//  keyCreatorFromEntropy.swift
//  BitKeys
//
//  Created by Peter on 6/16/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import Foundation
import BigInt
import UIKit

public func diceKey(viewController: UIViewController, userRandomness: BigInt, password: String) -> [String:Any] {
    
    var words = ""
    var recoveryPhrase = String()
    let data = BigUInt(userRandomness).serialize()
    var success = Bool()
    let sha256OfData = BTCSHA256(data)
    var keyArray = [[String:String]]()
        
    if let mnemonic = BTCMnemonic.init(entropy: sha256OfData as Data!, password: password, wordListType: BTCMnemonicWordListType.english) {
            
        words = mnemonic.words.description
        let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
        let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
        recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
        if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0") {
            
            keychain.key.isPublicKeyCompressed = true
            let xpub = (keychain.extendedPublicKey)!
            
            for i in 0 ... 19 {
               
                let int = UInt32(i)
                let addressHD = (keychain.key(at: int).address.string)
                let privateKey = (keychain.key(at: int).wif)!
                let publicKey = (keychain.key(at: int).compressedPublicKey.hex())!
                keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                
            }
            
            keychain.key.clear()
            success = true
            
            return ["seedDict":["seed":recoveryPhrase, "xpub":xpub], "keyArray":keyArray, "success":success]
            
        }
        
    } else {
        
        return ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
    
}


