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
import BigInt

var keyArray = [[String:String]]()
var dictToReturn = [String:Any]()

public func createKeyChain(viewController: UIViewController, password: String, diceRolls: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    let bytesCount = 32
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    
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
            print("recoveryPhrase = \(recoveryPhrase)")
            
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
                dictToReturn = ["seedDict":["recoveryPhrase":recoveryPhrase, "xpub":xpub], "keyArray":keyArray, "success":true]
                
            }
            
        } else {
            
            dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    } else {
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}

public func importKeyChainFromWords(viewController: UIViewController, password: String, words: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    let wordArray = words.split(separator: " ")
        
    if let mnemonic = BTCMnemonic.init(words: wordArray, password: password, wordListType: BTCMnemonicWordListType.english) {
            
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
                dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":xpub], "keyArray":keyArray, "success":true]
                
            }
            
        } else {
            
            dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    return dictToReturn
    
}

public func importKeyChainFromXpub(viewController: UIViewController, xpub: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    if let watchOnlyKey = BTCKeychain.init(extendedKey: xpub) {
            
        watchOnlyKey.key.isPublicKeyCompressed = true
        let xpub = (watchOnlyKey.extendedPublicKey)!
            
        for i in 0 ... 19 {
                
            let int = UInt32(i)
            let addressHD = (watchOnlyKey.key(at: int).address.string)
            let privateKey = ""
            let publicKey = (watchOnlyKey.key(at: int).compressedPublicKey.hex())!
            keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                
        }
            
        watchOnlyKey.key.clear()
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":xpub], "keyArray":keyArray, "success":true]
            
    } else {
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}

public func importKeyChainFromXprv(viewController: UIViewController, xprv: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    if let keyChain = BTCKeychain.init(extendedKey: xprv) {
        
        keyChain.key.isPublicKeyCompressed = true
        let xpub = (keyChain.extendedPublicKey)!
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            let addressHD = (keyChain.key(at: int).address.string)
            let privateKey = (keyChain.key(at: int).privateKeyAddress.string)
            let publicKey = (keyChain.key(at: int).compressedPublicKey.hex())!
            keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
            
        }
        
        keyChain.key.clear()
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":xpub], "keyArray":keyArray, "success":true]
        
    } else {
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}
