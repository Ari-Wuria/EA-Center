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

class LaunchViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var internetAvailable: Bool!

    @IBOutlet weak var launchImageView: UIImageView!
    
    @IBOutlet weak var noInternetLabel: UILabel!
    @IBOutlet weak var noInternetDescLabel: UILabel!
    @IBOutlet weak var retryInternetButton: UIButton!
    
    private var presented = false
    
    var labelHidden = false
    
    weak var delegate: LaunchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNoInternetLabelVisibility(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkInternet()
        setImage()
    }
    
    func setImage(_ animated: Bool = false) {
        let deviceMode = getDeviceSize()
        let imageName: String
        switch deviceMode {
        case 1:
            imageName = "LaunchScreenTall"
        case 2:
            imageName = "LaunchScreeniPadVert"
        case 3:
            imageName = "LaunchScreeniPadHorz"
        case 4:
            imageName = "LaunchScreenNormal"
        default:
            imageName = ""
        }
        let launchImage = UIImage(named: imageName)
        launchImageView.image = launchImage
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
        
        delayAndShowMainScreen()
        
        return true
    }
    
    func delayAndShowMainScreen() {
        delay(1) {
            self.performSegue(withIdentifier: "ShowMain", sender: nil)
            self.presented = true
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
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if presented == false {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.setImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMain" {
            let dest = segue.destination as! UISplitViewController
            self.delegate?.launchScreenPresented(self, targetController: dest)
        }
    }
}

extension LaunchViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LaunchAnimator()
    }
}
