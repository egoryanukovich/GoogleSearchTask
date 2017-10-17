//
//  ViewController.swift
//  GoogleSearchTask
//
//  Created by Egor Yanukovich on 9/15/17.
//  Copyright © 2017 Egor Yanukovich. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController {

    let urlString = "https://www.google.com/search?q=%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82.%20how%20are%20u?"
    
    var urlRequest : String!
    @IBOutlet weak var containerView: UIView!
    var webView : WKWebView!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var containerButtomHeight: NSLayoutConstraint!
    @IBOutlet weak var fieldButtomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet weak var resultStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wkWebViewConfig = WKWebViewConfiguration()
        wkWebViewConfig.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
        webView = WKWebView(frame:self.containerView.frame, configuration: wkWebViewConfig)
        
        containerView.addSubview(webView)
        
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        searchField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        webView.removeObserver(self, forKeyPath: "loading")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        webView.frame = frame
        
        
        loadRequest(urlString)
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
        case "loading":
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
            
        default:
            break
        }
        
    }
    func keyboardWillShow(notification : NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            fieldButtomConstraint.constant = keyboardSize.height
            
            containerButtomHeight.constant += keyboardSize.height
            
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        
        fieldButtomConstraint.constant = 98
        containerButtomHeight.constant = 207
        
    }

    func loadRequest(_ urlString: String){
        myActivityIndicator.startAnimating()
        let url = URL(string: urlString)!
        let request = URLRequest(url:url)
        webView.load(request)
    }
    
    @IBAction func goBackAction(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func goForwardAction(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func getUrlOfPage(_ sender: UIButton) {
        let request : String? = urlRequest.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url =  "https://www.google.com/search?q=" + request!
        loadRequest(url)
        
        
        

    }
//    function getResultsAmount(id) {return JSON.stringify({"result": document.getElementById(id).innerText.split(" ")[2]})} getResultsAmount("resultStats")
    
    
}

extension ViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = searchField.text, !text.isEmpty {
        urlRequest = text
        }
        textField.resignFirstResponder()
    
        return true
    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        searchField.resignFirstResponder()
//        self.view.endEditing(true)
//    }
    
    
}
extension ViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        myActivityIndicator.stopAnimating()
        let js = "document.getElementById('resultStats').innerText.split(' ')[1]"
        var resultStatsString = ""
        webView.evaluateJavaScript(js, completionHandler: nil)
        webView.evaluateJavaScript(js) { (response, error) in
        if (response != nil) {
            resultStatsString = response as! String
            print(resultStatsString)
            
//            let myString = resultStatsString.replacingOccurrences(of: ",|0", with: "", options: .regularExpression, range: nil) // было:16,700,000 стало:167
          let myString = resultStatsString.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            print(myString)

            self.resultStatusLabel.text = String(describing: Int(myString)!)
        }
        }
      
    }
    //"function getResultsAmount(id) {return JSON.stringify({'result': document.getElementById(id).innerText.split(' ')[2]})} getResultsAmount('resultStats')"
    
}
