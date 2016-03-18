//
//  TakePicture.swift
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
import AVFoundation
import CoreLocation

class TakePicture: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    var imageDic: Dictionary<String, AnyObject> = [:]
    var imageDicArray: Array<Dictionary<String, AnyObject>> = []
    var currentDevicePosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified

    // カメラ
    var mySession: AVCaptureSession!
    var myCamera: AVCaptureDevice!
    var myImageOutput:AVCaptureStillImageOutput!
    var myVideoLayer: AVCaptureVideoPreviewLayer!
    let captureDevices = AVCaptureDevice.devices()
    
    var get_image: UIImage!
    var locationManager = CLLocationManager()
    var lat: CLLocationDegrees!
    var lng: CLLocationDegrees!
    
    @IBOutlet var filter_select: UIButton!
    @IBOutlet var shutter: UIButton!
    
    @IBOutlet var preview_view: UIView!
    @IBOutlet var filters: UIScrollView!
    @IBOutlet var frame_image: UIImageView!
    @IBOutlet var frames: UIImageView!

    @IBAction func switch_camera(sender: UIButton) {

        // switch another devicePosition
        if self.currentDevicePosition == AVCaptureDevicePosition.Front {
            switchCameraInput(AVCaptureDevicePosition.Back)
        } else {
            switchCameraInput(AVCaptureDevicePosition.Front)
        }
    }

    @IBAction func select_filter(sender: UIButton) {
        
        if self.filters.alpha > 0 {
            self.filters.alpha = 0  // 隠す
        } else {
            self.filters.alpha = 0.8  // 表示
        }
    }
    
    func prepareFrames() {
        
        self.imageDicArray = getImageDicFromDb()
        print("imageDicArray :\(self.imageDicArray)")
        
        let numOfImages = self.imageDicArray.count
        let frameMinX = CGRectGetMinX(self.frames.frame)
        let frameMinY = CGRectGetMinY(self.frames.frame)
        let frameWidth = self.frames.frame.width
        let frameHeight = self.frames.frame.height
        
        self.filters.contentSize = CGSizeMake( ( frameMinX + frameWidth ) * CGFloat(numOfImages), frameHeight)
        
        print(numOfImages)
        for var i = 0; i < numOfImages; i++ {
            
            let gesture = UITapGestureRecognizer(target: self, action: "image_tapped:")
            let image: UIImageView = UIImageView()
            let filename = String(self.imageDicArray[i]["img"]!)
            
            image.addGestureRecognizer(gesture)
            image.tag = i
            image.userInteractionEnabled = true
            image.image = UIImage(contentsOfFile: getPathInImagesDir(filename))
            image.frame = CGRectMake( ( frameMinX + frameWidth ) * CGFloat(i), frameMinY, frameWidth, frameHeight)
            
            self.filters.addSubview(image)
        }
    }
    
    func image_tapped(sender: UITapGestureRecognizer) {
        
        self.shutter.enabled = true
        
        self.frame_image.frame = self.preview_view.bounds
        self.frame_image.image = (sender.view as! UIImageView).image
        self.frame_image.alpha = 0.8
        
        let tappedTag: Int = (sender.view as! UIImageView).tag
        self.imageDic = self.imageDicArray[tappedTag]
        
        for subview in self.frame_image.subviews {
            subview.removeFromSuperview()
        }
        
    }
    
    
    // シャッターボタンで実行する
    @IBAction func takePhoto(sender: AnyObject) {
        
        // ビデオ出力に接続する
        let myAVConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得する
        myImageOutput.captureStillImageAsynchronouslyFromConnection(myAVConnection,
            completionHandler: { (imageDataBuffer, error) -> Void in
                
                // ビデオ画像をキャプチャする
                let myImageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                self.get_image = UIImage(data: myImageData)
                
                // カメラロールに追加する
                // UIImageWriteToSavedPhotosAlbum(stillImage!, self, nil, nil)

                if self.currentDevicePosition == AVCaptureDevicePosition.Front {
                    self.get_image = self.flipHorizontal(self.get_image)  // フロントカメラ利用時は左右反転
                }
                
                self.performSegueWithIdentifier("SaveShareView", sender: nil)

                
                // START debug code : by hara
                print("get_image    (size)      : \(self.get_image.size)")
                print("frame_image  (image.size): \(self.frame_image.image!.size)")
                print("preview_view (frame.size): \(self.preview_view.frame.size)")
                // END  debug code : by hara
                
        })
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.myVideoLayer.frame = self.preview_view.bounds
    }
    
    func setupCamera(devicePosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified) {
        // セッションの作成　と　解像度設定
        mySession = AVCaptureSession()
        mySession.sessionPreset = AVCaptureSessionPresetPhoto
        
        setCameraDevice(devicePosition)
        
        // カメラからVideoInputを取得する
        do{
            // 入力元
            let videoInput = try AVCaptureDeviceInput(device: myCamera)
            mySession.addInput(videoInput)
            
            // 出力先
            myImageOutput = AVCaptureStillImageOutput()
            mySession.addOutput(myImageOutput)
            
            // 画像を表示するプレビューレイヤーをセット
            self.myVideoLayer = AVCaptureVideoPreviewLayer(session: mySession)
            self.myVideoLayer.frame = self.preview_view.bounds
            self.myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspect
            
            //最背面になるようにプレビューレイヤを挿入する
            self.preview_view.layer.insertSublayer(self.myVideoLayer, atIndex: 0)
            
            //セッション開始
            mySession.startRunning()
            
        } catch let error as NSError{
            print("カメラは使えません。\(error)")
        }

    }

    func switchCameraInput(devicePosition: AVCaptureDevicePosition) {
        setCameraDevice(devicePosition)
        
        // カメラからVideoInputを取得し、入れ替える
        do{
            // 新しい入力を取得
            let videoInput = try AVCaptureDeviceInput(device: myCamera)

            
            //セッション停止
            mySession.stopRunning()
            
            // 現在のInput を削除し、新しい入力を割当
            let allInputs = mySession.inputs
            for input in allInputs {
                mySession.removeInput(input as! AVCaptureInput)
            }
            mySession.addInput(videoInput)
            
            
            //　セッション再開
            mySession.startRunning()
            
        } catch let error as NSError{
            print("カメラは使えません。\(error)")
        }

    
    }

    func setCameraDevice(devicePosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified){
        //撮影に使うカメラをデバイス一覧から設定
        for device in captureDevices{
            if devicePosition == AVCaptureDevicePosition.Unspecified || devicePosition == AVCaptureDevicePosition.Back {
                // バックカメラで撮影する
                if(device.position == AVCaptureDevicePosition.Back) {
                    myCamera = device as! AVCaptureDevice
                    currentDevicePosition = device.position
                }
            }
            else {
                // フロントカメラで撮影する
                if(device.position == AVCaptureDevicePosition.Front) {
                    myCamera = device as! AVCaptureDevice
                    currentDevicePosition = device.position
                }
            }
        }
        
    }

    
    /// 撮影した画像の長辺側の反転を行う
    func flipHorizontal(image: UIImage) -> UIImage {
        let originalOrientation = image.imageOrientation
        
        // UIImageに設定されている回転方向を初期化したUIImageを作成。デフォルト：'UIImageOrientation.Up'
        let landscapeImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: .Up)
        
        UIGraphicsBeginImageContextWithOptions(landscapeImage.size, false, landscapeImage.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // 左右反転の為に、原点とScaleを変更　（landscapeImageは横画像になっている事を考慮し、上下反転用の設定を行う）
        CGContextTranslateCTM(context, 0, landscapeImage.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        // 画像を描画
        landscapeImage.drawInRect(CGRectMake(0,0,landscapeImage.size.width, landscapeImage.size.height))

        // 画像取得
        let flipHorizontalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // 保存しておいたUIImageの回転を再設定する
        return UIImage(CGImage: flipHorizontalImage.CGImage!, scale: flipHorizontalImage.scale, orientation: originalOrientation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("KAO HAME", comment: "")
        
        // Clear Text on BackButton on NavigationBar
        let backButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        self.shutter.enabled = false
        
        self.filters.delegate = self
        self.filters.pagingEnabled = true
        self.filters.scrollEnabled = true

        
        // 現在地の取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            print("didChangeAuthorizationStatus:\(status)")
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        
        // カメラの準備
        setupCamera(AVCaptureDevicePosition.Back)
        
        
        // フレームの準備と表示
        dispatch_async(dispatch_get_main_queue(), {
            self.prepareFrames()
        })

        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            if self.shutter.enabled == false {
              self.select_filter(self.filter_select)
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // TODO : フレーム選択済み処理 from FrameCollection
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            case "SaveShareView":
                
                let finallview = segue.destinationViewController as! SaveShareView

                finallview.get_image = self.get_image
                finallview.image_latitude = self.lat
                finallview.image_longitude = self.lng
                finallview.preview_view = self.preview_view
                finallview.frame_image = self.frame_image
                finallview.image_dic = self.imageDic
            
            default: break
        }
    }
    
    
    // 位置情報取得成功
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation]){
        print("緯度：\(manager.location!.coordinate.latitude)")
        print("経度：\(manager.location!.coordinate.longitude)")
        
        self.lat = manager.location!.coordinate.latitude
        self.lng = manager.location!.coordinate.longitude
        
        self.locationManager.stopUpdatingLocation()
    }
    
    // 位置情報取得失敗
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        print("error")
    }
    
    // 現状のステータス状態を表示します
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus")
        var statusStr = ""
        switch status {
        case .NotDetermined:        statusStr = "NotDetermined"
        case .Restricted:           statusStr = "Restricted"
        case .Denied:               statusStr = "Denied"
        case .Authorized:           statusStr = "Authorized"
        case .AuthorizedWhenInUse:  statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
    }

}
