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
