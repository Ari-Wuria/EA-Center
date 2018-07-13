//
//  HelperFunctions.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/12.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

func delay(_ time: Double, _ block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
}
