//
//  KeychainSwiftConstants.swift
//  Storage
//
//  Created by Fazliddinov Iskandar on 18/05/25.
//


import Foundation
import Security


struct KeychainSwiftConstants {
    
    static var accessGroup: String { return toString(kSecAttrAccessGroup) }
    
    static var accessible: String { return toString(kSecAttrAccessible) }
    
    static var attrAccount: String { return toString(kSecAttrAccount) }
    
    static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
    
    static var klass: String { return toString(kSecClass) }
    
    static var matchLimit: String { return toString(kSecMatchLimit) }
    
    static var returnData: String { return toString(kSecReturnData) }
    
    static var valueData: String { return toString(kSecValueData) }
    
    static var returnReference: String { return toString(kSecReturnPersistentRef) }
    
    static var returnAttributes : String { return toString(kSecReturnAttributes) }
    
    static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
      
    static func toString(_ value: CFString) -> String {
      return value as String
    }
}