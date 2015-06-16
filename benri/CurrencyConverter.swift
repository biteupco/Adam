//
//  CurrencyConverter.swift
//  adam
//
//  Created by ariyasuk-k on 6/15/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation

struct CurrencyConverter {
    
    static var symbolDict: NSDictionary? {
        get {
            if let path = NSBundle.mainBundle().pathForResource("CurrencyList", ofType: "plist") {
                return NSDictionary(contentsOfFile: path)
            } else {
                return nil
            }
            
        }
    }
    
    static func codeToSymbol(code:String) -> String {
        if let dict = CurrencyConverter.symbolDict {
            // Use your dict here
            for (key, value) in dict {
                let myKey = key as! String
                if code == myKey {
                    return value as! String
                }
            }
        }
        return code
    }
    
    static func symbolToCode(symbol:String) -> String {
        if let dict = CurrencyConverter.symbolDict {
            // Use your dict here
            for (key, value) in dict {
                let myValue = value as! String
                if symbol == myValue {
                    return key as! String
                }
            }
        }
        return symbol
    }
}