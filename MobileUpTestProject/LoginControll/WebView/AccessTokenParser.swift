//
//  AccessTokenParser.swift
//  MobileUpTestProject
//
//  Created by Максим on 04.04.2022.
//

import Foundation

class AccessTokenParser {
    public static func parse(url: URL) -> String? {
        let str = url.description.replacingOccurrences(of: "#", with: "?")
        guard let items = URLComponents(string: str)?.queryItems else { return nil }
        guard let item = items.filter({$0.name == "access_token"}).first else { return nil }
        return item.value
    }
}
