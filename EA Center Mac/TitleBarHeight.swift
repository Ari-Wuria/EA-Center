//
//  TitleBarHeight.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/20.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}
