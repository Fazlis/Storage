//
//  UserDefaultsStorage.swift
//  Storage
//
//  Created by Fazliddinov Iskandar on 18/05/25.
//


import Foundation
import Interfaces


public final class UserDefaultsStorage: StorageWritable, StorageReadable {
    private let defaults: UserDefaults
    private let lock = NSLock()

    public init(suiteName: String? = nil) {
        self.defaults = suiteName != nil ? UserDefaults(suiteName: suiteName)! : .standard
    }

    public func set<T: Codable>(_ value: T, forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            throw StorageError.encodingFailed
        }
    }

    public func get<T: Codable>(forKey key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }

        guard let data = defaults.data(forKey: key) else { return nil }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }

    public func remove(_ key: String) throws {
        lock.lock()
        defer { lock.unlock() }

        guard defaults.object(forKey: key) != nil else {
            throw StorageError.removalFailed("Key \(key) not found in UserDefaults.")
        }
        defaults.removeObject(forKey: key)
    }

    public func removeAll() throws {
        lock.lock()
        defer { lock.unlock() }

        let dictionary = defaults.dictionaryRepresentation()
        guard !dictionary.isEmpty else {
            throw StorageError.removalFailed("UserDefaults is already empty.")
        }
        dictionary.keys.forEach { defaults.removeObject(forKey: $0) }
    }
}
