//
//  WebViewController.swift
//  MobileUpTestProject
//
//  Created by Максим on 04.04.2022.
//

import Foundation
import UIKit
import WebKit

protocol TokenDelegate: AnyObject {
    func handleNewValidToken(newToken: String)
}

class WebViewController: UIViewController {
    weak var accessTokenDelegate: TokenDelegate?
    
    var webView: WKWebView? {
        return view as? WKWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
    }
    
    func clearAuthCookie() {
        webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                self.webView?.configuration.websiteDataStore.httpCookieStore.delete(cookie)
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let token = AccessTokenParser.parse(url: url) {
                dismiss(animated: false, completion: nil)
                accessTokenDelegate?.handleNewValidToken(newToken: token)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}
