import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    private static let appId = 8125315
    
    private var webController = WebViewController()
    private let authServiceProvider = AuthServiceProvider(forAppId: appId)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebController()
        setupTitleLabel()
        setupLoginButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCurrentSession()
    }
    
    func setupWebController() {
        webController.accessTokenDelegate = self
    }
    
    func setupTitleLabel() {
        titleLabel.lineBreakStrategy = .hangulWordPriority
    }
    
    func setupLoginButton() {
        loginButton.layer.cornerRadius = 10
    }
    
    func checkCurrentSession() {
        if authServiceProvider.hasActiveSession() {
            guard let token =  authServiceProvider.currentToken else { return }
            print(token)
            processSuccessLogin(token: token)
        }
    }
    
    func processSuccessLogin(token: String) {
        let session = authServiceProvider.createNewSession(withAccessToken: token)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "navigationController") as! UINavigationController
        
        let galleryController = storyboard.instantiateViewController(
                    identifier: "galleryController",
                    creator: { coder in
                        GalleryViewController(coder: coder, session: session)
                    }
                )
        
        galleryController.logoutAction = { [weak self] in
            self?.logoutAction()
        }
        navController.viewControllers[0] = galleryController
        print(navController.viewControllers, "controllers")
        present(navController, animated: true, completion: nil)
    }
    
    func logoutAction() {
        authServiceProvider.closeSession()
        webController.clearAuthCookie()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        newLoginAction()
    }
    
    func newLoginAction() {
        let request = authServiceProvider.getRequestForAuth()
        webController.webView?.load(request)
        showWebView()
    }
    
    func showWebView() {
        present(webController, animated: true, completion: nil)
    }
}

extension LoginViewController: TokenDelegate {
    
    // precondition: newToken is valid token
    func handleNewValidToken(newToken: String) {
        processSuccessLogin(token: newToken)
    }
}
