//
//  BitcoinCore.swift
//  DiceKey
//
//  Created by Peter on 08/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import Security
import UIKit
import BigInt

public func createBitcoinCoreKeyChain(viewController: UIViewController, password: String, diceRolls: String) -> [String:Any] {
    
    var success = Bool()
    let bytesCount = 32
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    var keyArray = [[String:String]]()
    var dictToReturn = [String:Any]()
    
    if status == errSecSuccess {
        
        var data = Data(bytes: randomBytes)
        
        if diceRolls != "" {
            
            if let diceIntCheck = BigUInt.init(diceRolls) {
                
                let diceData = BigUInt(diceIntCheck).serialize()
                data = data + diceData
                
            }
            
        }
        
        let sha256OfData = BTCSHA256(data) as Data
        
        if let mnemonic = BTCMnemonic.init(entropy: sha256OfData, password: password, wordListType: BTCMnemonicWordListType.english) {
            
            let words = mnemonic.words.description
            let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
            print("recoveryphrase = \(recoveryPhrase)")
            
            if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/0'/0'") {
                
                keychain.key.isPublicKeyCompressed = true
                let xpub = (keychain.extendedPublicKey)!
                
                for i in 0 ... 19 {
                    
                    let int = UInt32(i)
                    let addressHD = keychain.key(at: int).address.string
                    let privateKey = (keychain.key(at: int).wif)!
                    let publicKey = (keychain.key(at: int).compressedPublicKey.hex())!
                    keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                    
                }
                
                keychain.key.clear()
                success = true
                dictToReturn = ["seedDict":["seed":recoveryPhrase, "xpub":xpub], "keyArray":keyArray, "success":success]
                
            }
            
        } else {
            
            dictToReturn = ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    } else {
        
        dictToReturn = ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}
