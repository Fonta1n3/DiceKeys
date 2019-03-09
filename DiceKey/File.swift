//
//  File.swift
//  DiceKey
//
//  Created by Peter on 07/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation
import Security
import UIKit
import BigInt

public func createBrainWallet(viewController: UIViewController, password: String, diceRolls: String) -> [String:Any] {
    
    var success = Bool()
    let bytesCount = 16
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    var keyArray = [[String:String]]()
    var dictToReturn = [String:Any]()
    
    if status == errSecSuccess {
        
        let data = Data(bytes: randomBytes)
        
        if let mnemonic = BTCMnemonic.init(entropy: data, password: password, wordListType: BTCMnemonicWordListType.english) {
            
            let words = mnemonic.words.description
            let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            
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
                dictToReturn = ["seedDict":["recoveryPhrase":recoveryPhrase, "xpub":xpub], "keyArray":keyArray, "success":success]
                
            }
            
        } else {
            
            dictToReturn = ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    } else {
        
        dictToReturn = ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}
