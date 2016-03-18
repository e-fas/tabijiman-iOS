//
//  MoreInfo.swift
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
import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class MoreInfo: UIViewController, UITextViewDelegate {
    
    static let placeImage = UIImage(named: "icon_location_name.png")
    static let frameImage = UIImage(named: "icon_frame_name.png")
    static let collectionImage = UIImage(named: "icon_pin_l.png")
    static let noImage = UIImage(named: "img_frame.png")
    
    static let go_button_jaImage = UIImage(named: "btn_go_s.png")
    static let search_button_jaImage = UIImage(named: "btn_more.png")
    static let take_picture_jaImage = UIImage(named: "btn_take_photo_s.png")
    static let frame_get_button_jaImage = UIImage(named: "btn_frame_get_on.png")
    static let GetFrameImage_jaImage = UIImage(named: "get_frame.png")


    var dic: Dictionary<String, AnyObject>? = [:]
    var take_pic_flag: Bool!    // 写真をとるボタンの表示
    var frame_get_flag: Bool!   // フレームGETボタンの表示
    var color: String!          // カラーリングの属性決定
    var distance_flag: Bool! = false        // ViewControllerからの遷移時。取得可能フレームの場合 true
    var getFrameFlag: Bool! = false         // ViewControllerからの遷移時。取得済みフレームの場合 true
    var fromCollectionFlag: Bool! = false   // FrameCollectionからの遷移時に true
    var initFrameFlag: Bool = false         // FrameCollectionからの遷移時。initフレームの場合 true

    @IBOutlet var gotoCenter: NSLayoutConstraint!
    @IBOutlet var view_color: UIView!
    @IBOutlet var effectView: UIVisualEffectView!
        
    @IBOutlet var title_view: UILabel!
    @IBOutlet weak var icon_image: UIImageView!
    @IBOutlet var address: UILabel!
    @IBOutlet var img_view: UIImageView!
    @IBOutlet var test_viewer: UITextView!
    @IBOutlet var head_view: UIView!
    @IBOutlet var frame_get_action_view: UIView!
    @IBOutlet var get_image: UIImageView!
    @IBOutlet weak var GetFrameImage: UIImageView!
    
    
    @IBOutlet var go_button: UIButton!
    @IBOutlet var search_button: UIButton!
    @IBOutlet var take_picture: UIButton!
    @IBOutlet var frame_get_button: UIButton!
    
    @IBAction func frame_get( sender: UIButton ) {
        
        // AppSetting.startUp_flag = false
        
        if self.distance_flag! {
            
            // 取得フレームの表示
            self.get_image.image = img_view.image!
            
            self.frame_get_action_view.fadeIn(.Normal, completed: nil)
            
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.frame_get_action_view.fadeOut(.Normal, completed: nil)
            })
            
            // 画像を表示して、フォルダへ保存
            let image = UIImagePNGRepresentation(img_view.image!)
            
            let filename = title_view.text! + ".png"
            let imageFilePath = AppSetting.imagesPath + filename
            image!.writeToFile(imageFilePath, atomically: true)
            
            // 保存したファイル名で元の画像ファイルへのURLを上書き
            self.dic!["img"] = filename as String
            
            print("start to insert: \(dic)")
            
            // Dbへ保存
            _ = SQLite.sharedInstance.insertData("getFrame", datas: self.dic!)
            
            // 取得済みフラグをたてる
            SQLite.sharedInstance.enableGetFlag(self.dic!["name"]! as! String)
        } else {
            // Can not get
            let alertController = UIAlertController(title: NSLocalizedString("oops!", comment: "") , message: NSLocalizedString("You are so far from the place. Design can not be gotton. \n Please come to the place & try it again.", comment: ""), preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func take_picture( sender: UIButton ) {
        
        performSegueWithIdentifier("TakePicture", sender: nil)
    }
    
    @IBAction func go_there(sender: UIButton) {
        
        let locate: CLLocation = CLLocation(latitude: self.dic!["lat"]! as! CLLocationDegrees, longitude: self.dic!["lng"]! as! CLLocationDegrees)
        
        self.showLocation(locate)
    }
    
    @IBAction func searching(sender: UIButton) {
        
        let url : NSString = "http://google.com/#q=" + self.dic!["name"]!.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLFragmentAllowedCharacterSet() )!
        let searchURL : NSURL = NSURL(string: url as String)!
        
        // ブラウザ起動
        if UIApplication.sharedApplication().canOpenURL(searchURL){
            UIApplication.sharedApplication().openURL(searchURL)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let logoImage = UIImageView(image: UIImage(named: "HeadLogo"))
        logoImage.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = logoImage
        
        self.judgeLocalizationUiImage()

        // color set of 'place'
        self.view_color.backgroundColor = UIColor.rgbColor(0xedf5d3)
        self.address.textColor = UIColor.rgbColor(0x85a80f)
        self.icon_image.image = MoreInfo.placeImage

        if let _ = self.dic!["address"] as? String {
            
            self.address.text = self.dic!["address"] as? String
        }else {
            self.address.text = "テストテストテストテスト"
            self.address.hidden = true
        }
        
        self.title_view.text = self.dic?["name"] as? String
        self.title_view.sizeToFit()
        
        self.test_viewer.text = self.dic!["desc"] as? String
        
        self.test_viewer.delegate = self  // TODO : delegateで何を行っているのか確認
        self.test_viewer.font = UIFont.systemFontOfSize(CGFloat(17))
        
        self.take_picture.hidden = !take_pic_flag
        self.search_button.hidden = frame_get_flag
        self.frame_get_button.hidden = !frame_get_flag
        
        if self.color == "frame" {
            // color set of 'frame'
            self.view_color.backgroundColor = UIColor.rgbColor(0xffecca)
            self.address.textColor = UIColor.rgbColor(0xff6000)
            self.icon_image.image = MoreInfo.frameImage
        }
        if self.color == "collection" {
            // color set of 'collection'
            self.view_color.backgroundColor = UIColor.rgbColor(0xffecca)
            self.address.textColor = UIColor.rgbColor(0xff6000)
            self.icon_image.image = MoreInfo.collectionImage
        }
        
        if !take_pic_flag {
            gotoCenter.constant = 0
        }
        
        if !self.initFrameFlag && !self.fromCollectionFlag {
            // should be Place

            let url = String(self.dic!["img"]!)
            if ((url.rangeOfString("://") != nil) || (url.rangeOfString("https://")) != nil) {
            
                let request = NSMutableURLRequest(URL: NSURL(string: url)! , cachePolicy:.ReloadIgnoringLocalCacheData, timeoutInterval:2.0)
                
                Alamofire.request(.GET, request)
                    .validate(statusCode: 200..<300)
                    .response { ( request, response, data, error ) in
                    
                    if (error == nil) {
                    
                        if let check = UIImage(data: data!) {
                            self.img_view.image = check
                            
                            if !self.getFrameFlag! {
                                
                                // 未取得の場合、EffectView を表示する
                                //self.effectView.alpha = 1
                                self.effectView.hidden = false
                            }
                        }
                    } else {
                        // HTTP request failed
                        print(error)
                        self.img_view.image = MoreInfo.noImage
                    }
                }
            } else {
                // set No Image
                self.img_view.image = MoreInfo.noImage
            }
        } else if !self.initFrameFlag {
            
            // should be getFrame
            if (self.dic!["img"] != nil) {
                let filename = self.dic!["img"] as! String
                self.img_view.image = UIImage(contentsOfFile: getPathInImagesDir(filename))
            } else {
                // fail to get getFrame
                self.img_view.image = MoreInfo.noImage
            }
        } else {
            
            // should be initFile
            let filename = self.dic!["img"] as! String
            let imageData = getDataFromResource(filename)
            self.img_view.image = UIImage(data: imageData!)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // UITextView を 上寄せ表示するための設定 （上寄せの概念がレイアウト上はない）
        self.test_viewer.setContentOffset(CGPointZero, animated: false)
    }
    
    // 目的地周辺の地図を表示する(アプリへ)
    func showLocation(location: CLLocation) {
        let daddr = NSString(format: "%f,%f", location.coordinate.latitude,  location.coordinate.longitude)
        var urlString: String
        
        if self.dic?["address"] != nil {
            urlString = "http://maps.apple.com/?ll=\(daddr)&q=\(self.dic!["name"]!)&z=15"
        }else {
            urlString = "http://maps.apple.com/?ll=\(daddr)&q=\(self.dic!["name"]!)&z=15"
        }

        let encodedUrl = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: encodedUrl)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller
        
        if segue.identifier! == "TakePicture" {
            
            // let constant: TakePicture = segue.destinationViewController as! TakePicture
        }
    }

    /// UI言語判断と設定
    func judgeLocalizationUiImage() {
        if AppSetting.langUi == "ja" {
            self.go_button.setImage(MoreInfo.go_button_jaImage, forState: .Normal)
            self.search_button.setImage(MoreInfo.search_button_jaImage, forState: .Normal)
            self.take_picture.setImage(MoreInfo.take_picture_jaImage, forState: .Normal)
            self.frame_get_button.setImage(MoreInfo.frame_get_button_jaImage, forState: .Normal)
            self.GetFrameImage.image = MoreInfo.GetFrameImage_jaImage
        }
    }


}
