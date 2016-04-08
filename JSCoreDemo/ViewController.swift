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
        let requestURLString = NSBundle.mainBundle().pathForResource("JavaScriptCoreDemo", ofType: "html")
        
        if let requestURLString = requestURLString,
            let requestURL = NSURL(string: requestURLString) {
            //  加载 html
            webView.loadRequest(NSURLRequest(URL: requestURL))
        }
        
        webView.delegate = self
        
    }
    
    @IBAction func rightBarButtonClick(sender: UIBarButtonItem) {
        //  调用 JS
        callJS()
        
        //  直接注入一段JS运行
        //        evaluateJS()
        
    }
    
    func callJS() {
        let params : [AnyObject]! = ["Hello JS! \(arc4random() % 10)"]
        context?.objectForKeyedSubscript("fromNative").callWithArguments(params)
    }
    
    func evaluateJS() {
        context?.evaluateScript("alert('你运行了一段JS')")
        
        //  也可以写成这样，效果同 callJS
        //        context?.evaluateScript("fromNative(' 你运行了一段JS')")
        
    }
    
    func fromJS(paramFromJS:AnyObject?) {
        
        Alert
            .showIn(self)
            .preferredStyle(.ActionSheet)
            .title("Call From JS")
            .message("检测到了来自 JS 的调用！")
            .addAction("我知道了", style: .Cancel, handler: nil)
        
        guard let paramFromJS = paramFromJS else {
            return
        }
        
        print("✅ param from JavaScript is:")
        print(paramFromJS)
        
    }
    
    func registerCallBack() {
        
        let callBack : @convention(block) (AnyObject?) -> Void = { [weak self] (paramFromJS) -> Void in
            self?.fromJS(paramFromJS)
            //            print(paramFromJS!.dynamicType)
        }
        
        context?.setObject(unsafeBitCast(callBack, AnyObject.self), forKeyedSubscript: "callNative")
    }
}

extension ViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
        registerCallBack()
    }
}

