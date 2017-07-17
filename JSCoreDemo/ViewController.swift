//
//  ViewController.swift
//  JSCoreDemo
//
//  Created by 王策 on 16/4/8.
//  Copyright © 2016年 王策. All rights reserved.
//

import UIKit
import JavaScriptCore
import Halo

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var context : JSContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  html 文件路径
        let requestURLString = Bundle.main.path(forResource: "JavaScriptCoreDemo", ofType: "html")
        
        if let requestURLString = requestURLString,
            let requestURL = URL(string: requestURLString) {
            //  加载 html
            webView.loadRequest(URLRequest(url: requestURL))
        }
        
        webView.delegate = self
        
    }
    
    @IBAction func rightBarButtonClick(_ sender: UIBarButtonItem) {
        //  调用 JS
        callJS()
        
        //  直接注入一段JS运行
        //        evaluateJS()
        
    }
    
    func callJS() {
        let params : [AnyObject]! = ["Hello JS! \(arc4random() % 10)" as AnyObject]
        _ = context?.objectForKeyedSubscript("fromNative").call(withArguments: params)
    }
    
    func evaluateJS() {
        _ = context?.evaluateScript("alert('你运行了一段JS')")
        
        //  也可以写成这样，效果同 callJS
        //        context?.evaluateScript("fromNative(' 你运行了一段JS')")
        
    }
    
    func fromJS(_ paramFromJS:AnyObject?) {
        
        _ = Alert
            .showIn(self)
            .preferredStyle(.actionSheet)
            .title("Call From JS")
            .message("检测到了来自 JS 的调用！")
            .addAction("我知道了", style: .cancel, handler: nil)
        
        guard let paramFromJS = paramFromJS else {
            return
        }
        
        print("✅ param from JavaScript is:")
        print(paramFromJS)
        
    }
    
    func registerCallBack() {
        
        let callBack : @convention(block) (AnyObject?) -> Void = { [weak self] (paramFromJS) -> Void in
            DispatchQueue.main.async {
                self?.fromJS(paramFromJS)
            }
            print(type(of: paramFromJS!))
        }
        context?.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "callNative" as NSCopying & NSObjectProtocol)
    }
}

extension ViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        registerCallBack()
    }
}

