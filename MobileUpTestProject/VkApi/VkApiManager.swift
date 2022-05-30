//
//  File.swift
//  VkApiManager
//
//  Created by Максим on 04.04.2022.
//

// manager - предоставляет данные и кидает транспортные ошибки по необходимости, такой местный alamofire

import Foundation

public class VkApiSession {
    private static let tokenKey = "ACCESS_TOKEN"
    private (set) var session: URLSession
    private var appId: Int
    
    static var accessToken: String? { // небезопасно
        get {
            UserDefaults.standard.string(forKey: Self.tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.tokenKey)
        }
    }
    
    init(appId: Int, accessToken: String) {
        self.appId = appId
        session = Self.configuredSession()
        Self.accessToken = accessToken
    }
    
    private static func configuredSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 30_000_000, diskCapacity: 0, directory: nil)
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
    }
    
    typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (DataTaskResult) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            let response = response as! HTTPURLResponse
            completionHandler(.success((response, data!)))
        }.resume()
    }
    
    public func closeSession() {
        Self.accessToken = nil
        self.session.finishTasksAndInvalidate()
    }
}
