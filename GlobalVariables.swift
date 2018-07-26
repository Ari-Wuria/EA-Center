//
//  GlobalVariables.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

// Used to define global variables

import Foundation

//let MainServerAddress = "http://jerrytomlouise.asuscomm.com:81/eacenter"
//let MainServerAddress = "http://jerryshenming.6655.la:81/eacenter"

// Local testing only
let MainServerAddress = "http://192.168.50.100/eacenter"

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

// Other notification keys
let ManagerSelectionChangedNotification = Notification.Name("eacenter.managerselectionchanged")
let EAUpdatedNotification = Notification.Name("eacenter.eaupdated")
let ManagerDescriptionUpdatedNotification = Notification.Name("eacenter.descupdated")
let EACreatedNotification = Notification.Name("eacenter.neweacreated")
