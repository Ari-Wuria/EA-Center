//
//  Delay.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/20.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation
import Dispatch

func delay(_ seconds: Double, _ block: @escaping (() -> ())) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        block()
    }
}
