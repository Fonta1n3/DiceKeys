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

let segwit = SegwitAddrCoder()
var keyArray = [[String:String]]()
var dictToReturn = [String:Any]()

public func getSettings() -> [String:Any] {
    
    let userDefaults = UserDefaults.standard
    var bip44 = Bool()
    var bip84 = Bool()
    var electrumStandard = Bool()
    var electrumBip44 = Bool()
    var bitcoinCoreLegacy = Bool()
    var bitcoinCoreSegwit = Bool()
    var settings = [String:Any]()
    
    if userDefaults.object(forKey: "BIP44") != nil {
        
        bip44 = userDefaults.bool(forKey: "BIP44")
        
    } else {
        
        bip44 = true
        
    }
    
    if userDefaults.object(forKey: "BIP84") != nil {
        
        bip84 = userDefaults.bool(forKey: "BIP84")
        
    } else {
        
        bip84 = true
        
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
    
    let keyDerivationPath:String
    let keyChainDerivationPath:String
    let isLegacy:Bool
    let format:String
    
    if bip44 {
        
        keyDerivationPath = "m/44'/0'/0'/0"
        keyChainDerivationPath = "m/44'/0'/0'/0"
        isLegacy = true
        format = "bip44"
        
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
        
    } else if bip84 {
            
        keyDerivationPath = "m/84'/0'/0'/0"
        keyChainDerivationPath = "m/84'/0'/0'/0"
        isLegacy = false
        format = "bip84"
            
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
            
        
    } else if electrumStandard {
        
        keyDerivationPath = "m/0/0"
        keyChainDerivationPath = "m"
        isLegacy = true
        format = "electrumStandard"
        
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
        
    } else if electrumBip44 {
        
        keyDerivationPath = "m/44'/0'"
        keyChainDerivationPath = "m/44'/0'/0'/0"
        isLegacy = true
        format = "electrumBip44"
        
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
        
    } else if bitcoinCoreLegacy {
        
        keyDerivationPath = "m/0'/0'/0'"
        keyChainDerivationPath = "m"
        isLegacy = true
        format = "bitcoinCoreLegacy"
        
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
        
    } else if bitcoinCoreSegwit {
        
        keyDerivationPath = "m/0'/0'/0'"
        keyChainDerivationPath = "m"
        isLegacy = false
        format = "bitcoinCoreSegwit"
        
        settings = ["keyDerivationPath":keyDerivationPath, "keyChainDerivationPath":keyChainDerivationPath, "isLegacy":isLegacy, "format":format]
        
    }
    
    return settings
}

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
            //print("recoveryPhrase = \(recoveryPhrase)")
            
            let settings = getSettings()
            let format = settings["format"] as! String
                
            switch format {
                    
            case "bip44":
                    
                print("bip44")
                getBip44(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "bip84":
                
                print("bip84")
                getBip84(mnemonic: mnemonic, words: recoveryPhrase)
                    
            case "electrumStandard":
                    
                print("electrumStandard")
                getElectrumStandard(mnemonic: mnemonic, words: recoveryPhrase)
                    
            case "electrumBip44":
                    
                print("electrumBip44")
                getElectrumBip44(mnemonic: mnemonic, words: recoveryPhrase)
                    
            case "bitcoinCoreLegacy":
                    
                print("bitcoinCoreLegacy")
                getBitcoinCoreLegacyKeys(mnemonic: mnemonic, words: recoveryPhrase)
                    
            case "bitcoinCoreSegwit":
                    
                print("bitcoinCoreSegwit")
                getBitcoinCoreSegwitKeys(mnemonic: mnemonic, words: recoveryPhrase)
                    
            default:
                    
                print("bip44")
                getBip44(mnemonic: mnemonic, words: recoveryPhrase)
                    
            }
                
            
        } else {
            
            dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    } else {
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}

public func createBrainWallet(viewController: UIViewController, password: String, diceRolls: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    let bytesCount = 16
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    
    if status == errSecSuccess {
        
        let data = Data(bytes: randomBytes)
        
        if let mnemonic = BTCMnemonic.init(entropy: data, password: password, wordListType: BTCMnemonicWordListType.english) {
            
            let words = mnemonic.words.description
            let formatMnemonic1 = words.replacingOccurrences(of: "[", with: "")
            let formatMnemonic2 = formatMnemonic1.replacingOccurrences(of: "]", with: "")
            let recoveryPhrase = formatMnemonic2.replacingOccurrences(of: ",", with: "")
            print("recoveryPhrase = \(recoveryPhrase)")
            
            let settings = getSettings()
            let format = settings["format"] as! String
            
            switch format {
                
            case "bip44":
                
                print("bip44")
                getBip44(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "bip84":
                
                print("bip84")
                getBip84(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "electrumStandard":
                
                print("electrumStandard")
                getElectrumStandard(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "electrumBip44":
                
                print("electrumBip44")
                getElectrumBip44(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "bitcoinCoreLegacy":
                
                print("bitcoinCoreLegacy")
                getBitcoinCoreLegacyKeys(mnemonic: mnemonic, words: recoveryPhrase)
                
            case "bitcoinCoreSegwit":
                
                print("bitcoinCoreSegwit")
                getBitcoinCoreSegwitKeys(mnemonic: mnemonic, words: recoveryPhrase)
                
            default:
                
                print("bip44")
                getBip44(mnemonic: mnemonic, words: recoveryPhrase)
                
            }
            
        } else {
            
            dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
            
        }
        
    } else {
        
        dictToReturn = ["seedDict":["seed":"", "xpub":""], "keyArray":"", "success":false]
        
    }
    
    return dictToReturn
    
}

public func importKeyChainFromWords(viewController: UIViewController, password: String, words: String) -> [String:Any] {
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    let wordArray = words.split(separator: " ")
        
    if let mnemonic = BTCMnemonic.init(words: wordArray, password: password, wordListType: BTCMnemonicWordListType.english) {
        
        let settings = getSettings()
        let format = settings["format"] as! String
        
        switch format {
            
        case "bip44":
            
            print("bip44")
            getBip44(mnemonic: mnemonic, words: words)
            
        case "bip84":
            
            print("bip84")
            getBip84(mnemonic: mnemonic, words: words)
            
        case "electrumStandard":
            
            print("electrumStandard")
            getElectrumStandard(mnemonic: mnemonic, words: words)
            
        case "electrumBip44":
            
            print("electrumBip44")
            getElectrumBip44(mnemonic: mnemonic, words: words)
            
        case "bitcoinCoreLegacy":
            
            print("bitcoinCoreLegacy")
            getBitcoinCoreLegacyKeys(mnemonic: mnemonic, words: words)
            
        case "bitcoinCoreSegwit":
            
            print("bitcoinCoreSegwit")
            getBitcoinCoreSegwitKeys(mnemonic: mnemonic, words: words)
            
        default:
            
            print("bip44")
            getBip44(mnemonic: mnemonic, words: words)
            
        }
        
    } else {
            
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":""], "keyArray":"", "success":false]
            
    }
        
    return dictToReturn
    
}

public func importKeyChainFromXpub(viewController: UIViewController, xpub: String) -> [String:Any] {
    print("importKeyChainFromXpub")
    
    keyArray.removeAll()
    dictToReturn.removeAll()
    
    if let watchOnlyKey = BTCKeychain.init(extendedKey: xpub) {
                    
        watchOnlyKey.key.isPublicKeyCompressed = true
        let xpub = (watchOnlyKey.extendedPublicKey)!
            
        for i in 0 ... 19 {
                
            let int = UInt32(i)
            let addressHD = (watchOnlyKey.key(at: int).address.string)
            let publicKey = (watchOnlyKey.key(at: int).compressedPublicKey.hex())!
            keyArray.append(["privateKey":"", "address":addressHD, "publicKey":publicKey])
                
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
    
    getBip44FromXprv(xprv: xprv)
    
    let settings = getSettings()
    let format = settings["format"] as! String
    
    switch format {
        
    case "bip44":
        
        print("bip44")
        getBip44FromXprv(xprv: xprv)
        
    case "bip84":
        
        print("bip84")
        getBip84FromXprv(xprv: xprv)
        
    case "electrumStandard":
        
        print("electrumStandard")
        getElectrumStandardFromXprv(xprv: xprv)
        
    case "electrumBip44":
        
        print("electrumBip44")
        getBip44FromXprv(xprv: xprv)
        
    case "bitcoinCoreLegacy":
        
        print("bitcoinCoreLegacy")
        getBitcoinCoreLegacyKeysFromXprv(xprv: xprv)
        
    case "bitcoinCoreSegwit":
        
        print("bitcoinCoreSegwit")
        getBitcoinCoreSegwitKeysFromXprv(xprv: xprv)
        
    default:
        
        print("bip44")
        getBip44FromXprv(xprv: xprv)
        
    }
    
    return dictToReturn
    
}

private func getBitcoinCoreSegwitKeys(mnemonic: BTCMnemonic, words: String) {
    print("getBitcoinCoreSegwitKeys")
    
    if let bitcoinCoreKeyChain = mnemonic.keychain.derivedKeychain(withPath: "m") {
        
        bitcoinCoreKeyChain.key.isPublicKeyCompressed = true
        let bitcoinCoreXpub = bitcoinCoreKeyChain.extendedPublicKey
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let bitcoinCoreKey = bitcoinCoreKeyChain.key(withPath: "m/0'/0'/\(int)'") {
                
                let privateKey = (bitcoinCoreKey.wif)!
                let publicKey = (bitcoinCoreKey.compressedPublicKey.hex())!
                let compressedPKData = BTCRIPEMD160(BTCSHA256(bitcoinCoreKey.compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                    
                    let bech32Address = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                    keyArray.append(["privateKey":privateKey, "address":bech32Address, "publicKey":publicKey])
                    
                } catch {
                    
                    print("error getting bech32 addresses")
                    
                }
                
            }
            
        }
        
        bitcoinCoreKeyChain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":bitcoinCoreXpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBitcoinCoreLegacyKeys(mnemonic: BTCMnemonic, words: String) {
    print("getBitcoinCoreSegwitKeys")
    
    if let bitcoinCoreKeyChain = mnemonic.keychain.derivedKeychain(withPath: "m") {
        
        bitcoinCoreKeyChain.key.isPublicKeyCompressed = true
        let bitcoinCoreXpub = bitcoinCoreKeyChain.extendedPublicKey
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let bitcoinCoreKey = bitcoinCoreKeyChain.key(withPath: "m/0'/0'/\(int)'") {
                
                let privateKey = (bitcoinCoreKey.wif)!
                let publicKey = (bitcoinCoreKey.compressedPublicKey.hex())!
                let address = bitcoinCoreKey.address.string
                keyArray.append(["privateKey":privateKey, "address":address, "publicKey":publicKey])
                
            }
            
        }
        
        bitcoinCoreKeyChain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":bitcoinCoreXpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBip44(mnemonic: BTCMnemonic, words: String) {
    print("getBip44")
    
    let xpub:String
    
    if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0") {
        
        xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
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
    
}

private func getElectrumStandard(mnemonic: BTCMnemonic, words: String) {
    
    if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m") {
        
        let xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let key = keychain.key(withPath: "m/0/\(int)") {
                
                let addressHD = (key.address.string)
                let privateKey = (key.wif)!
                let publicKey = (key.compressedPublicKey.hex())!
                keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                
            }
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getElectrumBip44(mnemonic: BTCMnemonic, words: String) {
    
    if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'") {
        
        let xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let key = mnemonic.keychain.derivedKeychain(withPath: "m/44'/0'/0'/0/\(int)")?.key {
                
                let addressHD = (key.address.string)
                let privateKey = (key.wif)!
                let publicKey = (key.compressedPublicKey.hex())!
                keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                
            }
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBip84(mnemonic: BTCMnemonic, words: String) {
    
    let xpub:String
    
    if let keychain = mnemonic.keychain.derivedKeychain(withPath: "m/84'/0'/0'/0") {
        
        xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            let privateKey = (keychain.key(at: int).wif)!
            let publicKey = (keychain.key(at: int).compressedPublicKey.hex())!
            let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
            
            do {
                
                let bech32Address = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                keyArray.append(["privateKey":privateKey, "address":bech32Address, "publicKey":publicKey])
                
            } catch {
                
                print("error getting bech32 addresses")
                
            }
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":words, "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}


//xpriv
private func getBitcoinCoreSegwitKeysFromXprv(xprv: String) {
    print("getBitcoinCoreSegwitKeys")
    
    if let bitcoinCoreKeyChain = BTCKeychain.init(extendedKey: xprv) {
        
        bitcoinCoreKeyChain.key.isPublicKeyCompressed = true
        let bitcoinCoreXpub = bitcoinCoreKeyChain.extendedPublicKey
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let bitcoinCoreKey = bitcoinCoreKeyChain.key(withPath: "m/0'/0'/\(int)'") {
                
                let privateKey = (bitcoinCoreKey.wif)!
                let publicKey = (bitcoinCoreKey.compressedPublicKey.hex())!
                let compressedPKData = BTCRIPEMD160(BTCSHA256(bitcoinCoreKey.compressedPublicKey as Data!) as Data!) as Data!
                
                do {
                    
                    let bech32Address = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                    keyArray.append(["privateKey":privateKey, "address":bech32Address, "publicKey":publicKey])
                    
                } catch {
                    
                    print("error getting bech32 addresses")
                    
                }
                
            }
            
        }
        
        bitcoinCoreKeyChain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":bitcoinCoreXpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBitcoinCoreLegacyKeysFromXprv(xprv: String) {
    print("getBitcoinCoreSegwitKeys")
    
    if let bitcoinCoreKeyChain = BTCKeychain.init(extendedKey: xprv) {
        
        bitcoinCoreKeyChain.key.isPublicKeyCompressed = true
        let bitcoinCoreXpub = bitcoinCoreKeyChain.extendedPublicKey
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let bitcoinCoreKey = bitcoinCoreKeyChain.key(withPath: "m/0'/0'/\(int)'") {
                
                let privateKey = (bitcoinCoreKey.wif)!
                let publicKey = (bitcoinCoreKey.compressedPublicKey.hex())!
                let address = bitcoinCoreKey.address.string
                keyArray.append(["privateKey":privateKey, "address":address, "publicKey":publicKey])
                
            }
            
        }
        
        bitcoinCoreKeyChain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":bitcoinCoreXpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBip44FromXprv(xprv: String) {
    
    let xpub:String
    
    if let keychain = BTCKeychain.init(extendedKey: xprv).derivedKeychain(withPath: "m/44'/0'/0'/0") {
        
        xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            let addressHD = (keychain.key(at: int).address.string)
            let privateKey = (keychain.key(at: int).wif)!
            let publicKey = (keychain.key(at: int).compressedPublicKey.hex())!
            keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getElectrumStandardFromXprv(xprv: String) {
    
    if let keychain = BTCKeychain.init(extendedKey: xprv) {
        
        let xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            
            if let key = keychain.key(withPath: "m/0/\(int)") {
                
                let addressHD = (key.address.string)
                let privateKey = (key.wif)!
                let publicKey = (key.compressedPublicKey.hex())!
                keyArray.append(["privateKey":privateKey, "address":addressHD, "publicKey":publicKey])
                
            }
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}

private func getBip84FromXprv(xprv: String) {
    
    let xpub:String
    
    if let keychain = BTCKeychain.init(extendedKey: xprv).derivedKeychain(withPath: "m/84'/0'/0'/0") {
        
        xpub = keychain.extendedPublicKey
        keychain.key.isPublicKeyCompressed = true
        
        for i in 0 ... 19 {
            
            let int = UInt32(i)
            let privateKey = (keychain.key(at: int).wif)!
            let publicKey = (keychain.key(at: int).compressedPublicKey.hex())!
            
            let compressedPKData = BTCRIPEMD160(BTCSHA256(keychain.key(at: int).compressedPublicKey as Data!) as Data!) as Data!
            
            do {
                
                let bech32Address = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                keyArray.append(["privateKey":privateKey, "address":bech32Address, "publicKey":publicKey])
                
            } catch {
                
                print("error getting bech32 addresses")
                
            }
            
        }
        
        keychain.key.clear()
        
        dictToReturn = ["seedDict":["recoveryPhrase":"", "xpub":xpub], "keyArray":keyArray, "success":true]
        
    }
    
}

