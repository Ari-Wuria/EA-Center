//
//  BiometricAuth.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/10.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricAuth {
    enum BiometricType: String {
        case none = "Biometric"
        case touchID = "Touch ID"
        case faceID = "Face ID"
    }
    
    let context = LAContext()
    
    let loginReason = "Logging in with Touch ID"
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        }
    }
    
    func authenticate(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let message: String
                let type = self.biometricType()
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "Authentication failed"
                case LAError.userCancel?:
                    message = "Authentication cancelled"
                case LAError.userFallback?:
                    message = "Enter Password"
                case LAError.biometryNotAvailable?:
                    message = "\(type.rawValue) not available"
                case LAError.biometryNotEnrolled?:
                    message = "\(type.rawValue) not set up"
                case LAError.biometryLockout?:
                    message = "\(type.rawValue) is locked"
                default:
                    message = "\(type.rawValue) error"
                }
                DispatchQueue.main.async {
                    completion(message)
                }
            }
        }
    }
}
