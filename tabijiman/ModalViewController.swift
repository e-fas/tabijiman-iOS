//
//  ModalViewController.swift
//  tabijiman
//
//  Copyright (c) 2016 FUKUI Association of information & system industry
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit


protocol ModalViewControllerDelegate {
    func modalDidFinished(response: Bool)
}


class ModalViewController : UIViewController {
    
    var delegate: ModalViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.6)
        
        /// UI言語判断と設定
        let img = (AppSetting.langUi == "ja") ? UIImage(named: "go_fukui00.png") : UIImage(named: "go_fukui00-en.png")

        let imgView = UIImageView(frame: CGRectMake(0,0,194,285))
        imgView.image = img
        imgView.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        self.view.addSubview(imgView)

        imgView.userInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goSpecificLocation:"))

        
        let closeMeBtn = UIButton(frame: CGRectMake(0, 0, 300, 50))
        closeMeBtn.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 100)
        closeMeBtn.setTitle("Close", forState: .Normal)
        closeMeBtn.addTarget(self, action: "closeMe:", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeMeBtn)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goSpecificLocation( sender: UITapGestureRecognizer ) {
        dismissViewControllerAnimated(true, completion: nil)
        let response: Bool = true
        self.delegate.modalDidFinished(response)
    }

    func closeMe(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}