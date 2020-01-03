//
//  XFLNetworkStatus.swift
//  XFLNetwork
//
//  Created by xfl on 2020/1/2.
//

import UIKit
import Alamofire

public protocol XFLNetworkReachabilityDelegate:NSObject {
    /// 网络状态发生改变时的代理
    func networkReachability(_ reachability:XFLNetworkReachability,didChange:XFLNetworkStatus)
}

/// 网络状态
public enum XFLNetworkStatus {
    case notReachable
    case unknown
    case ethernetOrWiFi
    case wwan
}

/// 网络状态监听类
public class XFLNetworkReachability:NSObject {
    
    public static var sharedInstance = XFLNetworkReachability()
    public var status:XFLNetworkStatus = .unknown
    public weak var delegate:XFLNetworkReachabilityDelegate?
    fileprivate let reachabilityManager = NetworkReachabilityManager.default
    
    public override init() {
        super.init()
        monitorNetwork()
    }
}

// MARK: - 网络状态监听
extension XFLNetworkReachability {
    
    fileprivate func monitorNetwork() -> () {
        
        reachabilityManager?.startListening(onUpdatePerforming: { (netStatus) in
            switch netStatus {
            case .notReachable:
                self.status = .notReachable
            case .reachable(.ethernetOrWiFi):
                self.status = .ethernetOrWiFi
            case .reachable(.cellular):
                self.status = .wwan
            case .unknown:
                self.status = .unknown
            }
            self.delegate?.networkReachability(self, didChange: self.status)
        })
    }
}

