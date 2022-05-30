//
//  AuthServiceProvider.swift
//  MobileUpTestProject
//
//  Created by Максим on 04.04.2022.
//

import Foundation

//  получение url для авторизации через oauth
//  создание новой сессии по токену
//  проверка существующей сессии
//  парсинг токена лучше вынести в другой класс

struct ClientApp {
    let appId: Int
}

class AuthServiceProvider {
    private let app: ClientApp
    private var _vkSession: VkApiSession?
    
    var activeSession: VkApiSession? {
        _vkSession
    }
    
    var currentToken: String? {
        return VkApiSession.accessToken
    }
    
    init(forAppId id: Int) {
        self.app = ClientApp(appId: id)
    }
    
    func getRequestForAuth() -> URLRequest {
        return Self.getLoginRequest(forAppId: app.appId)
    }
    
    func createNewSession(withAccessToken token: String) -> VkApiSession {
        let session = VkApiSession(appId: app.appId, accessToken: token)
        _vkSession = session
        return session
    }
    
    func hasActiveSession() -> Bool {
        return VkApiSession.accessToken != nil
    }
    
    func closeSession() {
        _vkSession?.closeSession()
        _vkSession = nil
    }
    
    public static func getLoginRequest(forAppId appId: Int) -> URLRequest {
        var components = URLComponents(string: "https://oauth.vk.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "\(appId)"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "response_type", value: "token")
        ]
        let url = components.url!
        return URLRequest(url: url)
    }
}
