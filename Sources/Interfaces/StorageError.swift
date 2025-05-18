//
//  StorageError.swift
//  Storage
//
//  Created by Fazliddinov Iskandar on 18/05/25.
//


import Foundation


public enum StorageError: Error {
    case encodingFailed
    case decodingFailed
    case notFound
    case keychainError(status: OSStatus)
    case removalFailed(String)
    case unknown
}
