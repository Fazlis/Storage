////
//  StorageReadable.swift
//  Core
//
//  Created by Fazliddinov Iskandar on 08/05/25.
//  
//  Email: exclusive.fazliddinov@gmail.com
//  GitHub: https://github.com/Fazlis
//  LinkedIn: https://www.linkedin.com/in/iskandar-fazliddinov-2b8438279
//  Phone: (+992) 92-100-44-55
//



import Foundation


public protocol StorageReadable {
    func get<T: Codable>(forKey key: String) throws -> T?
}
