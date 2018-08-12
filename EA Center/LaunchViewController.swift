//
//  LaunchViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol LaunchViewControllerDelegate: class {
    func launchScreenPresented(_ controller: LaunchViewController, targetController: UISplitViewController)
}

class LaunchViewController: UIViewController, UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    var internetAvailable: Bool!

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var noInternetLabel: UILabel!
    @IBOutlet weak var noInternetDescLabel: UILabel!
    @IBOutlet weak var retryInternetButton: UIButton!
    
    @IBOutlet weak var biometricsButton: UIButton!
    @IBOutlet weak var biometricLabel: UILabel!
    @IBOutlet weak var biometricContainer: UIView!
    
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var skipLoginButton: UIButton!
    @IBOutlet weak var laterLabel: UILabel!
    @IBOutlet weak var loginMessageLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    private var presented = false
    
    var labelHidden = false
    
    weak var delegate: LaunchViewControllerDelegate?
    
    let authenticator = BiometricAuth()
    
    var logoUpwardYPosition: CGFloat! = 0
    
    var authenticationFailed = false
    
    var loginPending = false
    
    // Used to make text field out of the way on big iPads
    var originalContainerLocation: CGPoint?
    var switchingResponder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNoInternetLabelVisibility(false, animated: false)
        
        //biometricsButton.isHidden = true
        biometricContainer.isHidden = true
        
        switch authenticator.biometricType() {
        case .faceID:
            biometricsButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
            biometricLabel.text = "Press to unlock with Face ID"
        default:
            biometricsButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
            biometricLabel.text = "Press to unlock with Touch ID"
        }
        
        loginContainer.isHidden = true
        
        let newYLocation: CGFloat
        if self.view.traitCollection.verticalSizeClass == .regular && self.view.traitCollection.horizontalSizeClass == .regular {
            newYLocation = self.view.frame.size.height - self.view.frame.midY * 2 * (3/4)
        } else {
            newYLocation = self.view.frame.size.height - self.view.frame.midY * 2 * (5/6)
        }
        logoUpwardYPosition = newYLocation
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let connection = checkInternet()
        
        if connection {
            startup()
        }
    }
    
    func startup() {
        let displayed = UserDefaults.standard.bool(forKey: "firstdisplayed")
        // Test code
        if !displayed {
            // First time opening
            //UserDefaults.standard.set(true, forKey: "firstdisplayed")
            
            delayMoveLogoUp(0)
            loginContainer.isHidden = false
            loginContainer.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 1.8, options: .curveEaseInOut, animations: {
                self.loginContainer.alpha = 1
            }, completion: nil)
            return
        }
        
        let useBiometric = checkForBiometric()
        if useBiometric {
            delayMoveLogoUp(1)
            biometricContainer.isHidden = false
            biometricContainer.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 1.8, options: .curveEaseInOut, animations: {
                self.biometricContainer.alpha = 1
            }, completion: { _ in
                self.authenticate(self)
            })
            return
        }
        
        delayAndShowMainScreen()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction func skipLogin(_ sender: Any) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.loginContainer.isHidden = true
        }) { _ in
            self.loginContainer.removeFromSuperview()
            self.moveLogoBackAndShowMainScreen()
            UserDefaults.standard.set(true, forKey: "firstdisplayed")
            UserDefaults.standard.synchronize()
        }
    }
    
    func getDeviceSize() -> Int {
        // Using screen aspect ratio to determine launch image
        let bounds = UIScreen.main.nativeBounds
        let width = bounds.size.width
        let height = bounds.size.height
        if round(height / 19.5) == round(width / 9) {
            // iPhone X
            return 1
        } else if round(height / 4) == round(width / 3) {
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                // iPad Portrait
                return 2
            } else if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                // iPad Landscape
                return 3
            } else {
                return -1
            }
        } else if round(height / 16) == round(width / 9) {
            // Other iPhones
            return 4
        } else {
            return -1
        }
    }
    
    @discardableResult func checkInternet() -> Bool {
        let reachability = Reachability.forInternetConnection()
        let networkStatus = reachability?.currentReachabilityStatus()
        if networkStatus == NotReachable {
            if labelHidden {
                setNoInternetLabelVisibility(true, animated: false)
            }
            return false
        }
        
        //delayAndShowMainScreen()
        
        return true
    }
    
    func delayMoveLogoUp(_ mode: Int = 0) {
        delay(1) {
            let imageMover = CABasicAnimation(keyPath: "position")
            imageMover.isRemovedOnCompletion = false
            imageMover.fillMode = CAMediaTimingFillMode.forwards
            imageMover.duration = 1.0
            imageMover.fromValue = NSValue(cgPoint: self.logoImageView.center)
            imageMover.toValue = NSValue(cgPoint: CGPoint(x: self.logoImageView.center.x, y: self.logoUpwardYPosition))
            imageMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            imageMover.delegate = self
            self.logoImageView.layer.add(imageMover, forKey: "imageMover")
        }
    }
    
    func moveLogoBackAndShowMainScreen() {
        let imageMover = CABasicAnimation(keyPath: "position")
        imageMover.isRemovedOnCompletion = false
        imageMover.fillMode = CAMediaTimingFillMode.forwards
        imageMover.duration = 1.0
        imageMover.fromValue = NSValue(cgPoint: CGPoint(x: self.logoImageView.center.x, y: self.logoUpwardYPosition))
        imageMover.toValue = NSValue(cgPoint: self.logoImageView.center)
        imageMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.logoImageView.layer.removeAllAnimations()
        self.logoImageView.layer.add(imageMover, forKey: "imageMoverBack")
        self.delayAndShowMainScreen()
    }
    
    func checkForBiometric() -> Bool {
        let autoLogin = UserDefaults.standard.bool(forKey: "rememberlogin")
        let useBiometric = UserDefaults.standard.bool(forKey: "biometriclock")
        return authenticator.canEvaluatePolicy() && autoLogin && useBiometric
    }
    
    @IBAction func authenticate(_ sender: Any) {
        authenticator.authenticate { (message) in
            if let message = message {
                // TODO: Show login field with error message
                if message == "Authentication cancelled" {
                    // Just ignore the cancel requests
                    return
                }
                
                self.biometricContainer.isHidden = true
                self.loginContainer.isHidden = false
                self.skipLoginButton.isEnabled = false
                self.registerButton.isEnabled = false
                self.laterLabel.isHidden = true
                self.loginMessageLabel.text = message
                
                let email = UserDefaults.standard.string(forKey: "loginemail")
                self.usernameTextField.text = email
                self.usernameTextField.isEnabled = false
                self.usernameTextField.textColor = UIColor.lightGray
                
                self.authenticationFailed = true
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.biometricContainer.alpha = 0
                }, completion: { _ in
                    self.biometricContainer.removeFromSuperview()
                    self.moveLogoBackAndShowMainScreen()
                })
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        // Dismiss any text fields
        endEditing()
        if authenticationFailed {
            // Login from biometric
            let email = usernameTextField.text!
            if passwordTextField.text == String(data: KeychainHelper.loadKeychain(account: email)!, encoding: .utf8) {
                // Success
                usernameTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.2, animations: {
                    self.loginContainer.alpha = 0
                }) { _ in
                    self.loginContainer.removeFromSuperview()
                    self.moveLogoBackAndShowMainScreen()
                }
            } else {
                showAlert(withTitle: "Can not login", message: "Wrong password!")
            }
        } else {
            // Newcomer login
            if loginPending == true {
                return
            }
            
            loginPending = true
            
            let email = usernameTextField.text!
            let password = passwordTextField.text!
            
            guard AccountProcessor.validateEmail(email) else {
                showAlert(withTitle: "Invalid Email", message: "Please use a BCIS email")
                loginPending = false
                return
            }
            
            loginSpinner.startAnimating()
            
            let encryptedPass = AccountProcessor.encrypt(password)!
            
            AccountProcessor.sendLoginRequest(email, encryptedPass) { (success, errCode, errStr) in
                if success {
                    let saveSuccess = KeychainHelper.saveKeychain(account: email, password: password.data(using: .utf8)!)
                    if saveSuccess {
                        UserDefaults.standard.set(true, forKey: "rememberlogin")
                        UserDefaults.standard.set(email, forKey: "loginemail")
                        let authAsked = UserDefaults.standard.bool(forKey: "biometricasked")
                        if !authAsked {
                            self.askForEnableBiometric { (enable) in
                                if enable {
                                    UserDefaults.standard.set(true, forKey: "biometriclock")
                                }
                                UserDefaults.standard.set(true, forKey: "biometricasked")
                                UserDefaults.standard.set(true, forKey: "firstdisplayed")
                                UserDefaults.standard.synchronize()
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.loginContainer.alpha = 0
                                }, completion: { _ in
                                    self.loginContainer.removeFromSuperview()
                                    self.moveLogoBackAndShowMainScreen()
                                })
                            }
                        }
                    }
                } else {
                    self.loginSpinner.stopAnimating()
                    self.loginPending = false
                    self.showAlert(withTitle: "Login Failed", message: errStr! + " " + "(\(errCode!))")
                }
            }
        }
    }
    
    func askForEnableBiometric(_ completion: @escaping (Bool) -> Void) {
        if authenticator.canEvaluatePolicy() {
            let type = authenticator.biometricType()
            let alert = UIAlertController(title: "Turn on biometric?", message: "If you select yes, \(type.rawValue) will be required to open this app.\n\nYou can change this in the settings menu under the Me tab.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
                completion(false)
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                completion(true)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            completion(false)
        }
    }
    
    @IBAction func register(_ sender: Any) {
        showAlert(withTitle: "Not implemented yet", message: nil)
    }
    
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func delayAndShowMainScreen() {
        // Since we're never coming back, removing all container views
        delay(1.5) {
            self.performSegue(withIdentifier: "ShowMain", sender: nil)
            self.presented = true
            delay(1) {
                //self.logoImageView.removeFromSuperview()
                //self.biometricContainer.removeFromSuperview()
                //self.loginContainer.removeFromSuperview()
            }
        }
    }
    
    func setNoInternetLabelVisibility(_ visible: Bool, animated: Bool) {
        if animated {
            noInternetLabel.alpha = 0
            noInternetDescLabel.alpha = 0
            retryInternetButton.alpha = 0
            self.setNoInternetLabelVisibility(visible, animated: false)
            UIView.animate(withDuration: 0.8) {
                self.noInternetLabel.alpha = 1
                self.noInternetDescLabel.alpha = 1
                self.retryInternetButton.alpha = 1
            }
        } else {
            noInternetLabel.isHidden = !visible
            noInternetDescLabel.isHidden = !visible
            retryInternetButton.isHidden = !visible
            labelHidden = !visible
        }
    }
    
    @IBAction func retryConnectingToInternet(_ sender: Any) {
        let result = checkInternet()
        if result {
            setNoInternetLabelVisibility(false, animated: true)
            
            startup()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if presented == false {
            return .lightContent
        } else {
            return .default
        }
    }
    /*
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.setImage()
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMain" {
            let dest = segue.destination as! UISplitViewController
            self.delegate?.launchScreenPresented(self, targetController: dest)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

extension LaunchViewController: UITextFieldDelegate {
    // Test if another text field is about to become first responder
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder || passwordTextField.isFirstResponder {
            switchingResponder = true
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if view.traitCollection.horizontalSizeClass == .regular && view.traitCollection.verticalSizeClass == .regular {
            // iPad
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                // Landscape
                if !switchingResponder {
                    originalContainerLocation = loginContainer.center
                    let position = CGPoint(x: view.center.x, y: logoUpwardYPosition + 40)
                    UIView.animate(withDuration: 0.35, animations: {
                        self.loginContainer.center = position
                        self.logoImageView.alpha = 0
                    })
                }
            }
        } else if view.traitCollection.verticalSizeClass == .regular && view.traitCollection.horizontalSizeClass == .compact {
            // iPhone Portrait
            if !switchingResponder {
                originalContainerLocation = loginContainer.center
                UIView.animate(withDuration: 0.35, animations: {
                    self.loginContainer.center.y -= self.view.frame.size.height / 6
                    self.logoImageView.alpha = 0
                })
            }
        }
        switchingResponder = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !usernameTextField.isFirstResponder && !passwordTextField.isFirstResponder {
            // iPad
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                // Landscape
                if !switchingResponder {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.loginContainer.center = self.originalContainerLocation!
                        self.logoImageView.alpha = 1
                        self.originalContainerLocation = nil
                    })
                }
            } else if view.traitCollection.verticalSizeClass == .regular && view.traitCollection.horizontalSizeClass == .compact {
                // iPhone Portrait
                if !switchingResponder {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.loginContainer.center = self.originalContainerLocation!
                        self.logoImageView.alpha = 1
                        self.originalContainerLocation = nil
                    })
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            switchingResponder = true
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            switchingResponder = false
        } else if textField == passwordTextField {
            login(textField)
        }
        return true
    }
}

extension LaunchViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LaunchAnimator()
    }
}
