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

public func diceKey(viewController: UIViewController, userRandomness: BigInt, password: String) -> ([String:Any], Bool) {
    
    var words = ""
    var recoveryPhrase = String()
    let data = BigUInt(userRandomness).serialize()
    var success = Bool()
    
    let sha256OfData = BTCSHA256(data)
        
    if let mnemonic = BTCMnemonic.init(entropy: sha256OfData as Data!, password: password, wordListType: BTCMnemonicWordListType.english) {
            
        words = mnemonic.words.description
        let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
        let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
        recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
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


