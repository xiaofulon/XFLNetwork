//
//  XFLNetworkExtension.swift
//  XFLNetwork
//
//  Created by 肖富龙 on 2020/1/3.
//

import UIKit

extension String {
    
    func unicodeStringConvert() -> String? {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        return try? PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as? String
    }
}
