//
//  Const.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 1/25/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation

var equivalentEmptyDictionary = [String: String]()

class Const {
    private var constant = Dictionary<String, Dictionary<String,String>>()
    
    func getConst(type:String, key: String) -> String? {
        if constant.isEmpty || constant[type] == nil{
            return nil
        }
        else {
            var myConst = constant[type]
            if myConst?[key] != nil {
                return myConst?[key]
            }
        }
        return nil
    }
    
    func setConst(type:String, key: String, value: String) {
        var success:Bool
        if constant.isEmpty || constant[type] == nil{
            var newConst = [key : value]
            if let unwrappedPreviousValue = constant.updateValue(newConst, forKey: type) {
                //println("Replaced the previous value1: \(unwrappedPreviousValue)")
            } else{
                //println("Added a new value1")
            }
        }
        else{
            if let unwrappedPreviousValue = constant[type]?.updateValue(value, forKey: key) {
                //println("Replaced the previous value2: \(unwrappedPreviousValue)")
            } else {
                //println("Added a new value2")
            }

        }
    }
    
    func deleteConst(type:String, key: String) {
        if !constant.isEmpty &&  constant[type] != nil{
            constant[type]?[key] = nil
        }
    
    }
    
    class var sharedInstance : Const {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Const? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Const()
        }
        return Static.instance!
    }
}
