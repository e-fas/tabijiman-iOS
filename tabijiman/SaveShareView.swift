//
//  SaveShareView.swift
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
import ImageIO
import AssetsLibrary
import Photos
import CoreLocation
import Social
import Accounts
import CoreMedia
import CoreImage

class SaveShareView: UIViewController {
    
    static let share_button_jaImage = UIImage(named: "btn_share.png")
    static let save_button_jaImage = UIImage(named: "btn_save.png")
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var share_button: UIButton!
    @IBOutlet var save_button: UIButton!
    
    var get_image: UIImage! = UIImage()
    var frame_image: UIImageView! = UIImageView()
    var image_latitude: CLLocationDegrees!
    var image_longitude: CLLocationDegrees!
    var image_rect: CGRect!
    var remove_rect: CGRect!
    var cap_rect: CGRect!
    var preview_view: UIView!
    var image_scale: CGFloat!
    var image_dic: Dictionary<String, AnyObject>!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Share", comment: "")
        
        self.judgeLocalizationUiImage()
        
        // 合成処理　STEP1: 撮影した写真とフレームを合成。 STEP2: 不要な部分をクロップする
        
        // ----- STEP1: 撮影した写真とフレームを合成
        let imageWidth = (self.get_image.size.width)
        let imageHeight = (self.get_image.size.height)
        
        UIGraphicsBeginImageContext( CGSize( width: imageWidth, height: imageHeight ) )
        
        // 撮影した写真を描画
        self.get_image.drawInRect(CGRectMake(0,0,imageWidth,imageHeight))

        // ズレを判断したい
        // 撮影した写真の画面表示領域取得
        let imageOnPreveiwRect = AVMakeRectWithAspectRatioInsideRect( self.get_image.size, self.preview_view.bounds )
        let frameOnPreveiwRect = AVMakeRectWithAspectRatioInsideRect( self.frame_image.image!.size, self.preview_view.bounds )
        
        // それぞれ取れた : iPad2
            // レッサーパンダ（Preview に ピッタリ一致）の場合：
            // imageOnPreviewRect: (42.625, 0.0, 234.75, 313.0)
            // frameOnPreveiwRect: (42.625, 0.0, 234.75, 313.0)
            // ジュラっチック（横長。Preview左右に一致）の場合：
            // imageOnPreviewRect: (42.625, 0.0, 234.75, 313.0)
            // frameOnPreveiwRect: (0.0, 48.2554, 320.0, 216.489)
            // ゆめまる（縦長。Prevdiw上下に一致）の場合：
            // imageOnPreviewRect: (42.625, 0.0, 234.75, 313.0)
            // frameOnPreveiwRect: (77.7014, 0.0, 164.597, 313.0)
        
        // scale を算出。Previewに対して　カメラ画面を AspectFit させているので、Fitしてる辺から計算
        var scale : CGFloat
        if (imageOnPreveiwRect.minY == 0.0) {
            // 縦に最大化してる場合. height で比率を求める
            scale = self.get_image.size.height / self.preview_view.frame.size.height
            print("scale: \(scale) <based on Height>")
        } else {
            // 横に最大化している場合. width で比率を求める
            scale = self.get_image.size.width / self.preview_view.frame.size.width
            print("scale: \(scale) <based on  Width>")
        }

        // Preview上のサイズでお互いの表示位置のズレを確認
        let zureX = frameOnPreveiwRect.minX - imageOnPreveiwRect.minX
        let zureY = frameOnPreveiwRect.minY - imageOnPreveiwRect.minY
        let frameX = zureX * scale
        let frameY = zureY * scale

        // START debug code : by hara
        print("imageOnPreviewRect: \(imageOnPreveiwRect)")
        print("frameOnPreveiwRect: \(frameOnPreveiwRect)")
        print("zureX, zureY: \(zureX), \(zureY)")
        // END  debug code : by hara


        // フレームを描画
        let overlappedArea : CGRect = CGRectMake(frameX, frameY, imageWidth-frameX*2, imageHeight-frameY*2)
        self.frame_image.image?.drawInRect( overlappedArea )
        // self.frame_image.image?.drawInRect( CGRectMake(0,0,imageWidth,imageHeight) )  // 同じAspect比ならこれでOK

        // 合成完了
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        // ----- STEP1

        
        // ----- STEP2: 不要な部分をクロップする
        let cropRef   = CGImageCreateWithImageInRect(finalImage.CGImage, overlappedArea)
        let cropImage = UIImage(CGImage: cropRef!)
        // ----- STEP2

        
        self.image.image = cropImage

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save_image() {
        
        // メタデータを保存
        PHPhotoLibrary.sharedPhotoLibrary().performChanges( {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self.image.image!)
            changeRequest.location = CLLocation(latitude: self.image_dic["lat"]! as! CLLocationDegrees, longitude: self.image_dic["lng"]! as! CLLocationDegrees)
            }, completionHandler: nil
        )
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func share(sender: UIButton) {
        
        // 共有する項目
        let name = self.image_dic["name"]! as! String
        let shareText = name + "\n " + AppSetting.shareTag
        let shareImage = self.image.image!
        let activityItems = [(shareText), shareImage]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil )
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePrint
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // UIActivityViewControllerを表示
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    /// UI言語判断と設定
    func judgeLocalizationUiImage() {
        if AppSetting.langUi == "ja" {
            self.share_button.setImage(SaveShareView.share_button_jaImage, forState: .Normal)
            self.save_button.setImage(SaveShareView.save_button_jaImage, forState: .Normal)
        }
    }

}
