//
//  KeychainStorage.swift
//  Storage
//
//  Created by Fazliddinov Iskandar on 18/05/25.
//


import Foundation
import Security
import Interfaces


public final class KeychainStorage: StorageWritable, StorageReadable {

    private let lock = NSLock()

    private var synchronizable: Bool = false
    private var accessGroup: String?
    private var lastResultCode: OSStatus = noErr
    private var lastQueryParameters: [String: Any] = [:]

    public init() {}

    public func set<T: Codable>(_ value: T, forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }

        let data: Data
        if let string = value as? String {
            guard let stringData = string.data(using: .utf8) else {
                throw StorageError.encodingFailed
            }
            data = stringData
        } else {
            do {
                data = try JSONEncoder().encode(value)
            } catch {
                throw StorageError.encodingFailed
            }
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)

        var attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        attributes = addAccessGroupWhenPresent(attributes)
        attributes = addSynchronizableIfRequired(attributes, addingItems: true)

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            throw StorageError.keychainError(status: status)
        }
    }

    public func get<T: Codable>(forKey key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }

        guard let data = getData(forKey: key) else { return nil }

        if T.self == String.self {
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            return string as? T
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func getData(forKey key: String) -> Data? {
        var query: [String: Any] = [
            KeychainSwiftConstants.klass: kSecClassGenericPassword,
            KeychainSwiftConstants.attrAccount: key,
            KeychainSwiftConstants.matchLimit: kSecMatchLimitOne,
            KeychainSwiftConstants.returnData: true
        ]

        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)

        lastQueryParameters = query

        var result: AnyObject?
        lastResultCode = SecItemCopyMatching(query as CFDictionary, &result)

        guard lastResultCode == errSecSuccess else {
            return nil
        }

        return result as? Data
    }

    public func remove(_ key: String) throws {
        lock.lock()
        defer { lock.unlock() }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw StorageError.removalFailed("Failed to remove value for key \(key) from Keychain.")
        }
    }

    public func removeAll() throws {
        lock.lock()
        defer { lock.unlock() }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw StorageError.removalFailed("Failed to clear all data from Keychain.")
        }
    }

    // MARK: - Helpers

    private func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        guard let accessGroup = accessGroup else { return items }
        var result = items
        result[KeychainSwiftConstants.accessGroup] = accessGroup
        return result
    }

    private func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        guard synchronizable else { return items }
        var result = items
        result[KeychainSwiftConstants.attrSynchronizable] = addingItems ? true : kSecAttrSynchronizableAny
        return result
    }
}
