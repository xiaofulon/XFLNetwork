//
//  ViewController.swift
//  XFLNetwork
//
//  Created by xiaofulon on 01/02/2020.
//  Copyright (c) 2020 xiaofulon. All rights reserved.
//

import UIKit
import XFLNetwork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getNetworkData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNetworkData() {
        
        let url = "https://api.jisuapi.com/recipe/search"
        let para = ["appkey":"372297eaa7402f85","keyword":"白菜","num":30] as [String : Any]
        XFLNetworkManager.sharedInstance.GET(url, parameters: para) { (response) in
            if response.error != nil {
                print("请求失败,\(String(describing: response.errorMsg))")
            }else{
               // print("请求成功,\(String(describing: response.responseObject))")
            }
        }
    }
}

