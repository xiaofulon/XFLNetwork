//
//  XFLNetworkConstant.swift
//  XFLNetwork
//
//  Created by 肖富龙 on 2020/1/3.
//

import UIKit

// 打印从网络请求的数据unicode转utf8

public func XFLNLog<T>(_ message: T) {
    
    #if DEBUG
    
    if let mess = message as? String {
        if let utf8String = mess.unicodeStringConvert() {
            print("\(utf8String)")
        }else{
            print("\(mess)")
        }
    }else{
        print("\(message)")
    }
    
    #endif
}
