//
//  GlobalVariables.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

// Used to define global variables

import Foundation
#if os(OSX)
import CoreWLAN
#elseif os(iOS)
import SystemConfiguration.CaptiveNetwork
#endif

fileprivate let HomeServerAddress = "http://192.168.50.100/eacenter"
fileprivate let DynamicServerAddress1 = "http://jerryshenming.6655.la:81/eacenter"
fileprivate let DynamicServerAddress2 = "http://jerrytomlouise.asuscomm.com:81/eacenter"
fileprivate let SchoolServerAddress = "https://easlink.bcis.cn/eacenter"

#if os(OSX)
fileprivate var ssidName: String {
    return CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
}
/*
var MainServerAddress: String {
    return (ssidName == "Jerry5G" || ssidName == "Jerry2.4G" || ssidName == "Tom5G") ? HomeServerAddress : DynamicServerAddress1
}
 */
let MainServerAddress = SchoolServerAddress
#elseif os(iOS)
/*
// FIXME: Do something to make this work
func getCurrentWifiSSID() -> String {
    if let interface = CNCopySupportedInterfaces() {
        for i in 0..<CFArrayGetCount(interface) {
            let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interface, i)
            let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
            if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString), let interfaceData = unsafeInterfaceData as? [String : AnyObject] {
                // connected wifi
                //print("BSSID: \(interfaceData["BSSID"]), SSID: \(interfaceData["SSID"]), SSIDDATA: \(interfaceData["SSIDDATA"])")
                return interfaceData["SSID"] as! String
            } else {
                // not connected wifi
                return "No Wifi"
            }
        }
    }
    return "No Interface"
}

fileprivate var connectedSSID: String {
    let ssid = getCurrentWifiSSID()
    return ssid
}

var MainServerAddress: String {
    //print(connectedSSID)
    return (connectedSSID == "Tom5G" || connectedSSID == "Jerry5G" || connectedSSID == "Jerry2.4G") ? HomeServerAddress : DynamicServerAddress1
}
*/
// TODO: Dynamic check SSID too
//let MainServerAddress = HomeServerAddress
//let MainServerAddress = DynamicServerAddress2

let MainServerAddress = SchoolServerAddress
#endif

// AES keys and iv
// Change key before moving onto production run
// Generated using RANDOM.ORG
// This is used to encrypt passwords
let GlobalAESKey = "HhNedYLf2a5mZnyCF5nH0WTEcU5OvvZn"
let GlobalAESIV = "752Dh5l3SV5biDuc"
// Experimenting with securing API with AES. If it works great then we will move this into production.
// Current API has no security and bad guys can tamper the links to update EAs without the app or owner's permission
// Using AES for the hash, hash iv will be randomly generated and sent using hashkey param
// The key will be kept private within this app and the server
let GlobalAPIEncryptKey = "Xd3kanp4ujl63wQU1RByh7lXWehzwTgE"
// Key to encrypt
let GlobalAPIHash = "EJopPs6ohpwuk31fppMqDUxUx9NYZg4w"

// Login notification keys
let LoginSuccessNotification = Notification.Name("eacenter.loginsuccessnotification")
let LogoutNotification = Notification.Name("eacenter.logoutnotification")

// Manager notification keys
let ManagerSelectionChangedNotification = Notification.Name("eacenter.managerselectionchanged")
let EAUpdatedNotification = Notification.Name("eacenter.eaupdated")
let ManagerDescriptionUpdatedNotification = Notification.Name("eacenter.descupdated")
let EACreatedNotification = Notification.Name("eacenter.neweacreated")
let EADeletedNotification = Notification.Name("eacenter.deletedea")
let EAReceivedNewAttendeeNotification = Notification.Name("eacenter.newattendee")

// Other auxiliary notification keys
let ApplicationIsOutdatedNotification = Notification.Name("eacenter.appoutdated")

// iOS App Version number
#if os(iOS)
// 1: 0.9
// 2: 1.0
// No more 
let currentiOSVersion = 1
#endif

#if swift(>=4.2) && os(iOS)
import UIKit.UIGeometry
extension UIEdgeInsets {
    public static let zero = UIEdgeInsets()
}
#endif
