//
//  Bundle+loadJSON.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import Foundation

extension Bundle {
    /// Loads json from the main Bundle.
    /// - Parameter filename: The file name.
    /// - Returns: The decoded type of the json.
    func loadJSON<T: Codable>(_ type: T.Type, filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("File named \"\(filename)\" couldn't be found.")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode data. \(error)")
        }
    }
}
