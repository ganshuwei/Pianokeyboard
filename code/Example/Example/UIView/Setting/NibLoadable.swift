//
//  NibLoadable.swift
//  Example
//
//  Created by Shuwei Gan on 2021/8/1.
//  Copyright © 2021 Shuwei Gan. All rights reserved.
//

import UIKit

// 协议
protocol NibLoadable {
    // 具体实现写到extension内
}

// 加载nib
extension NibLoadable where Self : UIView {
    static func loadFromNib(_ nibname : String? = nil) -> Self {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}
