//
//  WebViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func runJS(_ sender: UIButton) {
        webView.stringByEvaluatingJavaScript(from: "alert('Hello World')")
    }
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    // MARK: - Variables
    var url: String!
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webpageURL = URL(string: url)
        let request = URLRequest(url: webpageURL!)
        webView.loadRequest(request)
    }

}



extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // URLs that this webview loads
        // Requests made by this URL, so we can stop anyone if we want
        
        // print(request.url!.absoluteString)
        
        if request.url!.absoluteString.range(of: "porn") != nil {
            return false
        }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        load.stopAnimating()
    }
}




