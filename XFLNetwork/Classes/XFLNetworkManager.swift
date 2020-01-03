//
//  NetworkManager.swift
//  CCBase_Example
//
//  Created by xfl on 2019/6/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Alamofire

/// 网络问题
public enum XFLNetworkError: Error {
    case networkNotReachable
    case urlWrong
    case serverWrong
}

/// MARK:- 响应类
public class XFLResponse: NSObject {
    public var requestUrl: URL?
    public var errorMsg: String?
    public var statusCode: Int = 0
    public var headers: [AnyHashable: Any]?
    public var responseObject: Any?
    public var error: Error?
    public var networkError:XFLNetworkError?
}

// 网络请求类
public class XFLNetworkManager:NSObject {

    public static var sharedInstance = XFLNetworkManager()
    public var authorization = ""
    public var timeOutDuration:TimeInterval = 15
    fileprivate lazy var taskRequests = [DataRequest]()
    fileprivate lazy var session:Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeOutDuration
        return Session(configuration: configuration)
    }()
}

// 网络请求接口
extension XFLNetworkManager {
    /// GET 请求
    public func GET(_ url: String, parameters: [String: Any]?, completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        self.request(url, method: HTTPMethod.get, parameters: parameters, completionHandler: completionHandler)
    }
    /// POST 请求
    public func POST(_ url: String, parameters: [String: Any]?, completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        self.request(url, method: HTTPMethod.post, parameters: parameters, completionHandler: completionHandler)
    }
    
    /// 取消请求
    public func cancelRequest(url:String) {
        let index = findRequsetDataIndex(url: url)
        if index > -1 {
            taskRequests[index].cancel()
            taskRequests.remove(at: index)
        }
    }
}

// MARK:- 请求
extension XFLNetworkManager {
    
    private func request(_ url: String, method: HTTPMethod = .get, parameters: [String: Any]?, completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        // 网络不可链接
        if XFLNetworkReachability.sharedInstance.status == .notReachable{
            let result = AFResult<Any>.failure(AFError.createURLRequestFailed(error: XFLNetworkError.networkNotReachable))
            self.wrapper(dataResponse: DataResponse(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: result),error: .networkNotReachable, completionHandler: completionHandler)
            return
        }
        
        guard let urlStr = urlEncoding(urlString: url) else {
            let result = AFResult<Any>.failure(AFError.createURLRequestFailed(error: XFLNetworkError.urlWrong))
            self.wrapper(dataResponse: DataResponse(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: result),error: .urlWrong ,completionHandler: completionHandler)
            return;
        }
        
        let httpheaders = HTTPHeaders.init(["authorization":authorization])
       
        XFLNLog("请求[\(method)]:\(urlStr)\n参数:\(String(describing: parameters))")
        
        let request = session.request(urlStr, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpheaders, interceptor: nil).responseJSON(queue: DispatchQueue.global(), options: .allowFragments) { (dataResponse) in
            
            XFLNLog("返回[\(method)]:\(urlStr)\n结果:\(dataResponse)]")
            
            if let error = dataResponse.error {
                if error.isExplicitlyCancelledError {return}// 取消请求的回调不执行
            }
            self.removeRequest(url: dataResponse.request?.url)
            self.wrapper(dataResponse: dataResponse, completionHandler: completionHandler)
        }
        
        taskRequests.append(request)
    }
    
    /// 请求成功移除请求
    fileprivate func removeRequest(url:URL?) {
        DispatchQueue.main.async {// 主线程中删除
            guard let urlString = url?.absoluteString else {return}
            let index = self.findRequsetDataIndex(url: urlString)
            if index > -1 {
                self.taskRequests.remove(at: index)
            }
        }
    }
    
    /// 数组中找出相应的请求index
    fileprivate func findRequsetDataIndex(url:String) ->Int {
        
        var index = -1
        for i in 0..<taskRequests.count {
            let dataRequest = taskRequests[i]
            if (dataRequest.request?.url?.absoluteString ?? "") == url {
                index = i
                break
            }
        }
        return index
    }
    
    /// 对特殊字符处理
    fileprivate func urlEncoding(urlString:String) -> String? {
        let characters = "`#%^{}\"[]|\\<> "
        return urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: characters).inverted)
    }
}

// MARK:- 解析数据
extension XFLNetworkManager {
    
    private func wrapper(dataResponse: AFDataResponse<Any>, error:XFLNetworkError? = nil ,completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        
        let response = XFLResponse()
        response.requestUrl = dataResponse.request?.url
        response.statusCode = dataResponse.response?.statusCode ?? 0
        response.headers = dataResponse.response?.allHeaderFields
        response.responseObject = dataResponse.value as? [String:AnyObject]
        response.error = dataResponse.error
        response.errorMsg = dataResponse.error?.localizedDescription
        response.networkError = error
    
        DispatchQueue.main.async {
            completionHandler(response)
        }
    }
}

// MARK:- 上传
extension XFLNetworkManager {
    /// 上传图片,5M内
    public func upload(_ url: String,image:UIImage, completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        
        let httpheaders = HTTPHeaders(["authorization":authorization])
        AF.upload(multipartFormData: { (data) in
            let imageData = image.jpegData(compressionQuality: 1.0) ?? Data()
            data.append(imageData, withName: "file", fileName: "head", mimeType: "image/*")
        }, to: url, usingThreshold: (5*1024*1024), method: .post, headers: httpheaders, interceptor: nil, fileManager: FileManager()).responseJSON { (dataResponse) in
            self.wrapper(dataResponse: dataResponse, completionHandler: completionHandler)
        }
    }
    /// 上传文件
    public func upload(_ url: String,data:Data,name:String,fileName:String,mime:String,completionHandler: @escaping (_ response: XFLResponse) -> Void) {
        
        let httpheaders = HTTPHeaders(["authorization":authorization])
        AF.upload(multipartFormData: { (upData) in
            upData.append(data, withName:name, fileName:fileName, mimeType:mime) //"image/*"
        }, to: url, method: .post, headers: httpheaders, interceptor: nil, fileManager: FileManager()).responseJSON { (dataResponse) in
           self.wrapper(dataResponse: dataResponse, completionHandler: completionHandler)
        }
    }
}

// MARK: - 下载文件
extension XFLNetworkManager {
    
    func download(_ url:String,completionHandler: @escaping (_ response:XFLResponse) -> Void) -> Void {
       
        AF.download(url).responseJSON { (downResponse) in
            
        }
    }
}
