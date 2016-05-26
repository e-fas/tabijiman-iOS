//
//  ViewController.swift
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
import CoreLocation
import MapKit
import Alamofire


class CustomAnnotation_P: MKPointAnnotation {
    
    var datas: Dictionary<String, AnyObject>!
    var lat: CLLocationDegrees!
    var lng: CLLocationDegrees!
}

class CustomAnnotation_F: MKPointAnnotation {
    
    var datas: Dictionary<String, AnyObject>!
    var lat: CLLocationDegrees!
    var lng: CLLocationDegrees!
    var GetFlag: Bool! = false
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, SPARQLDelegate, MKMapViewDelegate, UINavigationBarDelegate, ModalViewControllerDelegate {
    
    static let place_pin_image = UIImage(named: "InfoPin")
    static let frame_pin_image = UIImage(named: "FramePin")
    static let take_pic_button_jaImage = UIImage(named: "btn_take_photo.png")
    static let collection_button_jaImage = UIImage(named: "btn_frame_collection.png")
    static let GoFukui_jaImage = UIImage(named: "go_fukui01.png")
    
    dynamic var frame_dic_data: Array<Dictionary<String, AnyObject>>! = [[:]]
    dynamic var place_dic_data: Array<Dictionary<String, AnyObject>>! = [[:]]
    
    let locationManager = CLLocationManager()
    
    var region: MKCoordinateRegion!
    var more_info_data: Dictionary<String, AnyObject>!
    var place_annotations: [MKAnnotation]! = []
    var frame_annotations: [MKAnnotation]! = []
    var frame_flag: Bool = true
    var place_flag: Bool = true
    
    var distance_flag: Bool = false
    
    enum MapZoomLevel {
        case Train
        case Car
        case Walk
    }
    
    
    @IBOutlet var place_switch: UIImageView!
    @IBOutlet var frame_switch: UIImageView!
    @IBOutlet weak var GoFukui: UIImageView!
    
    @IBOutlet var train_button: UIImageView!
    @IBOutlet var walk_button: UIImageView!
    @IBOutlet var car_button: UIImageView!
    @IBOutlet var take_pic_button: UIImageView!
    @IBOutlet var collection_button: UIImageView!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet weak var go_fukui_button: UIImageView!
    
    func change_image( on_tag: Int?, off_tags:[Int]? ) {
        
        let on_images  = ["train_on.png" , "car_on.png" , "walk_on.png" , "pin_frame_on.png" , "pin_info_on.png" ]
        let off_images = ["train_off.png", "car_off.png", "walk_off.png", "pin_frame_off.png", "pin_info_off.png"]
        let views      = [train_button   , car_button   , walk_button   , frame_switch       , place_switch      ]
        
        if on_tag != nil {
            
            views[on_tag!].image = UIImage(named: on_images[on_tag!])
            
            switch on_tag! {
                
            case 3:
                
                if frame_flag {
                    views[on_tag!].image = UIImage(named: off_images[on_tag!])
                    self.mapView.removeAnnotations( self.frame_annotations )
                    
                }else {
                    views[on_tag!].image = UIImage(named: on_images[on_tag!])
                    self.mapView.addAnnotations( self.frame_annotations )
                }
                
                frame_flag = !frame_flag
                
            case 4:
                if place_flag {
                    views[on_tag!].image = UIImage(named: off_images[on_tag!])
                    self.mapView.removeAnnotations( self.place_annotations )
                }else {
                    views[on_tag!].image = UIImage(named: on_images[on_tag!])
                    self.mapView.addAnnotations( self.place_annotations )
                }
                
                place_flag = !place_flag
                
            default: break
            }
        }
        
        if off_tags != nil {
            for off_tag in off_tags! {
                
                views[off_tag].image = UIImage(named: off_images[off_tag])
            }
        }
    }
    
    func changeMapZoomLevel(zoomLevel: MapZoomLevel, trackingFollow: Bool) {
        
        if trackingFollow {
            self.mapView.userTrackingMode = .Follow
            self.mapView.userTrackingMode = .None
        } else {
            self.mapView.userTrackingMode = .None
        }

        self.region = self.mapView.region
        
        switch zoomLevel {
        case .Train:
            // 0.5 : 56.0km
            self.region.span.latitudeDelta = 0.5
            self.region.span.longitudeDelta = 0.5
        case .Car:
            // 0.15 : 16.8km
            region.span.latitudeDelta = 0.15
            region.span.longitudeDelta = 0.15
        case .Walk:
            // 0.05 : 5.6km
            // 0.03 : 3.3km
            region.span.latitudeDelta = 0.03
            region.span.longitudeDelta = 0.03
        }
        
        self.mapView.setRegion(self.region, animated:true)
    }
    
    /*
    * sender.view?.tag
    * -- 0: train_button
    * -- 1: car_button
    * -- 2: walk_button
    * -- 3: frame_switch
    * -- 4: place_switch
    * -- 5: TakePicture
    * -- 6: FrameCollection
    */
    func button_action( sender: UITapGestureRecognizer ) {
        
        switch sender.view!.tag {
            
        case 0:
            changeMapZoomLevel(MapZoomLevel.Train, trackingFollow:true)
            change_image( 0, off_tags: [1, 2] )
            
        case 1:
            changeMapZoomLevel(MapZoomLevel.Car, trackingFollow:true)
            change_image( 1, off_tags: [0, 2] )
            
        case 2:
            changeMapZoomLevel(MapZoomLevel.Walk, trackingFollow:true)
            change_image( 2, off_tags: [0, 1] )
            
        case 3:
            change_image( 3, off_tags: [] )
            
        case 4:
            change_image( 4, off_tags: [] )
            
        case 5:
            performSegueWithIdentifier("TakePicture", sender: nil)
            
        case 6:
            performSegueWithIdentifier("FrameCollection", sender: nil)
            
        default: break
            
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        switch keyPath! {
            case "place_dic_data":
                print("place in keyPath")
                
                SQLite.sharedInstance.truncateTable("place")  // delete all data in PlaceTable
                
                
                // use bulk insert
                _ = SQLite.sharedInstance.bulkInsertData("place", datass: self.place_dic_data)

                self.data2AnnotationsOnMap(self.place_dic_data, category: "place")
            
            case "frame_dic_data":
                print("frame in keyPath")

                SQLite.sharedInstance.truncateTable("frame")  // delete all data in frameTable
                
                for data in self.frame_dic_data {
                    _ = SQLite.sharedInstance.insertData("frame", datas: data)
                }
                self.data2AnnotationsOnMap(self.frame_dic_data, category: "frame")
            
            default: break
        }
        print("KeyPath >> \(keyPath), object >> \(object) in observeValueForKeyPath")
    }
    
    override func viewWillAppear(animated: Bool) {
                
        self.addObserver(self, forKeyPath: "place_dic_data", options: [.New, .Old], context: nil)
        self.addObserver(self, forKeyPath: "frame_dic_data", options: [.New, .Old], context: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func viewDidDisappear(animated: Bool) {
        
        removeObserver(self, forKeyPath: "place_dic_data")
        removeObserver(self, forKeyPath: "frame_dic_data")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController!.delegate = self
        self.navigationController!.navigationBar.barTintColor = UIColor.rgbColor(0x00b5e2)
        
        let logoImage = UIImageView(image: UIImage(named: "HeadLogo"))
        logoImage.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = logoImage
        
        // Clear Text on BackButton on NavigationBar
        let backButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        self.judgeLocalizationUiImage()
        
        self.train_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.car_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.walk_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.frame_switch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.place_switch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.take_pic_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        self.collection_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "button_action:"))
        
        self.go_fukui_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "confirmSpecificLocation:"))
        self.go_fukui_button.hidden = true
        
        self.mapView.delegate = self
        
        self.mapView.userTrackingMode = .Follow
        self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
        
        
        // 地図の設定：表示タイプを地図にして、CarレベルでZoomを設定
        self.mapView.mapType = MKMapType.Standard
        changeMapZoomLevel(MapZoomLevel.Car, trackingFollow:true)
        
        // async 準備
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        // DbSchema & CountUp num of Run
        AppSetting.udDbSchemaVer = 0  // AppVer 1.0.x = dbSchema 0
        AppSetting.inc_udCountRun()
        print("DbSchemaVer: \(AppSetting.udDbSchemaVer)")
        print("CountRun: \(AppSetting.udCountRun)")
        
        SQLite.sharedInstance.createSqlite()

        dispatch_group_async(group, queue, { () -> Void in
            self.SPARQL_query(AppSetting.SPARQL_query_place, category: "place")  // set self.place_dic_data
//            self.SPARQL_query(AppSetting.SPARQL_query_place_imgOption, category: "place")  // 画像なし観光情報も取得したい場合は、こっちを使う
            self.SPARQL_query(AppSetting.SPARQL_query_frame, category: "frame")  // set self.frame_dic_data
            self.parseInitFrameData()
        })
        


        // place の処理
        if AppSetting.placeDataBase.isExist {
            
            let place_data: Array<Dictionary<String, AnyObject>>! = SQLite.sharedInstance.selectData("place")

            if ( place_data != [] ) {
                
                self.data2AnnotationsOnMap(place_data, category: "place")
            } else {
                // update in observe func
            }
        }

        
        // frame の処理
        if AppSetting.frameDataBase.isExist {
            
            let frame_data: Array<Dictionary<String, AnyObject>>! = SQLite.sharedInstance.selectData("frame")
            
            if ( frame_data != [] ) {
                
                self.data2AnnotationsOnMap(frame_data, category: "frame")
            } else {
                // update in observe func
            }
        }
        
        
        // locationManageの設定
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        
        
        // GOTO FUKUIの画面パーツとの表示ルール
        // debug code in /* */ : by hara
        if (AppSetting.udCountRun % AppSetting.boarderOfCounter  /* 2 */) == 0 && checkFarFromFukui() /* true */ {
            
            self.go_fukui_button.hidden = false  // ボタンを表示
        }
        
    }
    
    /// SPARQLクエリを SPARQL().query で発行　（Asyncで実行）
    /// - parameter query: SPARQLクエリ
    /// - parameter category: Category <frame もしくは place>
    /// - returns: (none)
    func SPARQL_query( query: String, category: String ) {
        let endpoint = SPARQL()
        endpoint.delegate = self
        endpoint.query( query, category: category )
    }
    
    /// implimentation : func of protocol SPARQLDelegate
    func parsed(dic_data: Array<Dictionary<String, AnyObject>>, category: String) {
        
        // ハッシュ値の違いがあれば *_dic_data 更新して、新しいハッシュ値を保存
        let hash: NSData = NSKeyedArchiver.archivedDataWithRootObject(dic_data).sha256
        print("Hash of \(category) : \(hash)")
        
        if category == "place" {

            // place の処理
            if isHashChanged(hash, storedHash: AppSetting.udPlaceHash) {

                print("make a new place_dic in delegate.parsed")
                self.place_dic_data = dic_data
                AppSetting.udPlaceHash = hash
            }

        }
        else if category == "frame" {
            
            // frame の処理
            if isHashChanged(hash, storedHash: AppSetting.udFrameHash) {

                print("make a new frame_dic in delegate.parsed")
                self.frame_dic_data = dic_data
                AppSetting.udFrameHash = hash
            }

        }
    }
    
    /// initFrameData.plist を parse する。変更があれば更新処理をキック
    func parseInitFrameData() {

        var dic: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        var dic_data: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
        
        if let filePath: String = AppSetting.initFrameDataPath {
            dic = NSDictionary(contentsOfFile: filePath)! as! Dictionary
        } else {
            // Faild to open
        }
        
        // get initFrameData with own lang
        // 多言語が期待されるが initFrameData に言語情報がない場合は、英語を使う
        var langText = AppSetting.langSparql
        if dic[langText] == nil {
           langText = "en"
        }
        
        if dic[langText] != nil {
            for var i = 0; i < dic[langText]!.count!; i++ {
                
                let dics: Dictionary<String, AnyObject>! =
                [
                    "name": dic[langText]![i]["title"] as! String,
                    "desc": dic[langText]![i]["desc"] as! String,
                    "lat" : dic[langText]![i]["lat"] as! Double,
                    "lng" : dic[langText]![i]["lng"] as! Double,
                    "img" : dic[langText]![i]["img"] as! String,
                    "area": dic[langText]![i]["area"] as! Double,
                    "flag": true
                ]
                print(" dic[\(langText)][title] : \(dic[langText]![i]!["title"]!! as! String)")
//                print(" dic[ja][title] : \(dic["ja"]![i]!["title"]!! as! String)")
                
                dic_data.append(dics)
            }
        }
        else {
            // en 情報がなく ユーザーのlang設定が ja でもない場合
            // plist に ja , en を必須情報をとして設定する
            print("no 'ja' OR 'en' data in initFrameData.plist. Please fix the file.")
        }

        // ハッシュ値の違いがあれば createInitFrameDataを実行して更新。新しいハッシュ値を保存
        let hash: NSData = NSKeyedArchiver.archivedDataWithRootObject(dic_data).sha256
        print("Hash of initFrameData : \(hash)")
        
        // initFrame の処理
        if isHashChanged(hash, storedHash: AppSetting.udInitFrameHash) {
            
            print("create initFrame Db&files in parseInitFrameData")
            createInitFrameDb(dic_data)
            AppSetting.udInitFrameHash = hash
        }
    }
    
    /// initFrameDataから取り出した dic_data を使い Dbを更新
    func createInitFrameDb(dic_data: Array<Dictionary<String, AnyObject>>) {

        // Truncate first
        SQLite.sharedInstance.truncateTable("init")  // delete all data in initFrameTable

        var initFileNames: Array<String> = Array<String>()

        // Insert & make fileArray
        for item in dic_data {
            
            _ = SQLite.sharedInstance.insertData("init", datas: item)

            if let filename = item["img"] as? String {
                initFileNames.append(filename)
            }
        }
        
        setInitFrameImageFiles(initFileNames)

    }

    /// initFrame向けのImageFileを準備
    func setInitFrameImageFiles(initFileNames: Array<String>) {
        
        do {
            let fileManager = NSFileManager.defaultManager()
            try fileManager.createDirectoryAtPath(AppSetting.imagesPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Faild to wite folder
        }

        // 画像ファイルの保存
        for filename in initFileNames {

            let imageFilePath = getPathInImagesDir(filename)
//            print("imageFilePath >> \(imageFilePath)")
            
            let imageData = getDataFromResource(filename)
            if let saveImage: NSData? = UIImagePNGRepresentation(UIImage(data: imageData!)!) {
                if imageFilePath.isExist {
                    let res: Bool = saveImage!.writeToFile(imageFilePath, atomically: true)  // 上書き
                    print("file already exist, writeResut >> \(res)")
                } else {
                    let res: Bool = saveImage!.writeToFile(imageFilePath, atomically: true)
                    print("file did not exist, writeResult >> \(res)")
                }
            }
        }
    }
    
    /// NSData形式のHashを、String形式に変換して比較
    func isHashChanged(currentHash: NSData, storedHash: NSData) -> Bool {
        let currentHashString: String = currentHash.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let storedHashString: String = storedHash.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        if currentHashString == storedHashString {
            return false
        }
        return true
    }
    
    func data2AnnotationsOnMap(data: Array<Dictionary<String, AnyObject>>! , category: String) {
        
        var annotations: [MKAnnotation]! = []

        if category == "place" {
            
            // place の処理
            for item in data {
                
                let Annotation = makePlaceAnnotation(item)
                annotations.append( Annotation )
            }
            
            self.place_annotations = annotations
        }
        else if category == "frame" {
            
            // frame の処理
            for item in data {
                
                let Annotation = makeFrameAnnotation(item)
                annotations.append( Annotation )
            }
            
            self.frame_annotations = annotations
        }

        print("category : \(category) : addAnnotation on Map")
        self.mapView.userTrackingMode = .None
        self.mapView.addAnnotations(annotations)

    }

    

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier != nil {
            
            switch segue.identifier! {
                
            case "MoreInfo":
                
                let cellselected : MoreInfo = segue.destinationViewController as! MoreInfo
                cellselected.dic = self.more_info_data
                
                switch NSStringFromClass(sender!.dynamicType).componentsSeparatedByString(".").last! as String {
                case "CustomAnnotation_P":
                    cellselected.color = "place"
                    cellselected.take_pic_flag = false
                    cellselected.frame_get_flag = false
                    cellselected.getFrameFlag = true
                    
                case "CustomAnnotation_F":
                    cellselected.color = "frame"
                    cellselected.take_pic_flag = false
                    cellselected.frame_get_flag = true
                    cellselected.getFrameFlag =
                        ( self.more_info_data["flag"] == nil ) ? false : self.more_info_data["flag"] as! Bool
                    cellselected.distance_flag = self.distance_flag
                    
                default: break
                }
                
            case "FrameCollection":
                break
                
//                let frame_data: FrameCollection = segue.destinationViewController as! FrameCollection
                
            default: break
            }
        }
    }
    
    
    /// place ピンを作成
    /// - parameter item : Dictionary<String, AnyObject>
    /// - returns : CustomAnnotation_P
    func makePlaceAnnotation(item: Dictionary<String, AnyObject>) -> CustomAnnotation_P {
        
        let Annotation = CustomAnnotation_P()
        Annotation.coordinate = CLLocationCoordinate2DMake(item["lat"] as! CLLocationDegrees, item["lng"] as! CLLocationDegrees)
        Annotation.title = item["name"] as? String
        Annotation.datas = item
        Annotation.lat = item["lat"] as! CLLocationDegrees
        Annotation.lng = item["lng"] as! CLLocationDegrees
        
        return Annotation
    }
    
    /// frame ピンを作成
    /// - parameter item : Dictionary<String, AnyObject>
    /// - returns : CustomAnnotation_F
    func makeFrameAnnotation(item: Dictionary<String, AnyObject>) -> CustomAnnotation_F {
        
        let Annotation = CustomAnnotation_F()
        Annotation.coordinate = CLLocationCoordinate2DMake(item["lat"] as! CLLocationDegrees, item["lng"] as! CLLocationDegrees)
        Annotation.title = (item["name"]! as! String)
        Annotation.datas = item
        Annotation.lat = item["lat"]! as! CLLocationDegrees
        Annotation.lng = item["lng"]! as! CLLocationDegrees
        // Annotation.GetFlag = false

        if item["flag"] == nil {
            Annotation.GetFlag = false
        }
        else {
            Annotation.GetFlag = item["flag"] as! Bool
        }
        
        return Annotation
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        var reuseId: String!
        
        switch NSStringFromClass(annotation.dynamicType).componentsSeparatedByString(".").last! as String {
            
        case "CustomAnnotation_P": reuseId = "place"
            
        case "CustomAnnotation_F": reuseId = "frame"
            
        default: break
        }
        
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier( reuseId ) {
            
            annotationView.annotation = annotation
            return annotationView
        }else {
            
            let annotationView = MKAnnotationView( annotation: annotation, reuseIdentifier: reuseId )
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .InfoLight)
            
            switch NSStringFromClass(annotation.dynamicType).componentsSeparatedByString(".").last! as String {
                
            case "CustomAnnotation_P":
                annotationView.image = ViewController.place_pin_image
                
            case "CustomAnnotation_F":
                annotationView.image = ViewController.frame_pin_image
                
            default: break
            }
            
            annotationView.annotation = annotation
            
            return annotationView
        }
    }
    
    //Click on left or right button
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if (control == view.rightCalloutAccessoryView) {
            
            switch NSStringFromClass(view.annotation!.dynamicType).componentsSeparatedByString(".").last! as String {
                
            case "CustomAnnotation_P":
                print( ( view.annotation as! CustomAnnotation_P ).datas )
                self.more_info_data = ( view.annotation as! CustomAnnotation_P ).datas
                performSegueWithIdentifier("MoreInfo", sender: CustomAnnotation_P())
                
            case "CustomAnnotation_F":
                print( ( view.annotation as! CustomAnnotation_F ).datas )
                self.more_info_data = ( view.annotation as! CustomAnnotation_F ).datas
                self.distance_flag = self.check_distance( view.annotation! )
                performSegueWithIdentifier("MoreInfo", sender: CustomAnnotation_F())
                
            default: break
            }
        }
        else if (control == view.leftCalloutAccessoryView) {
            print("Button left pressed!")
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        self.mapView.reloadInputViews()
        print("regionDidChangeAnimated")
        
        let mRect = mapView.visibleMapRect
        let topMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect))
        let bottomMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect))
        let currentDist = MKMetersBetweenMapPoints(topMapPoint, bottomMapPoint)
        
        let zoomlevel = self.mapView.zoomLevel
        
        print("\(currentDist)m___zoomLevel\(zoomlevel)")
        
        if zoomlevel < 5 {
            
            self.mapView.setRegion( mapView.coordinateSpanWithMapView(zoomLebel: 5), animated: true )
        }
    }
    
    
    // ユーザーの位置とフレーム表示可能位置との距離を計測。frame annotation を開く時に使用
    func check_distance(annotation: MKAnnotation) -> Bool {
        
        let Annotation = annotation as! CustomAnnotation_F
        let a_latitude   : Double = Annotation.lat
        let a_longitude  : Double = Annotation.lng
        let go_location  : CLLocation = CLLocation(latitude: a_latitude, longitude: a_longitude)
        
        let b_latitude   : Double = self.mapView.userLocation.coordinate.latitude
        let b_longitude  : Double = self.mapView.userLocation.coordinate.longitude
        let now_location : CLLocation = CLLocation(latitude: b_latitude, longitude: b_longitude)
        
        let distance = go_location.distanceFromLocation(now_location)
        print("distance = \(distance)")
        
        // debug code : by hara
        // return true
        if (Annotation.datas["area"] != nil) {
            if distance < Annotation.datas["area"] as! Double {
                return true
            }
            return false
        }
        print("['area'] could not find.")
        return false
    }

    /// ユーザーの位置と福井県との距離を計測。GotoFukuiの表示条件に使用
    func checkFarFromFukui() -> Bool {
        // set location of JR Fukui Station
        let fukuiLocation = CLLocation(latitude: AppSetting.fukuiJrStationLat, longitude: AppSetting.fukuiJrStationLng)

        let lat: Double = self.mapView.userLocation.coordinate.latitude
        let lng: Double = self.mapView.userLocation.coordinate.longitude
        let location : CLLocation = CLLocation(latitude: lat, longitude: lng)
        
        let distance = fukuiLocation.distanceFromLocation(location)
        print("distance = \(distance)")
        
        if distance > AppSetting.boarderOfDistance { return true }
        
        return false
    }

    
    /// 福井へGOボタン押下後のアクション
    func confirmSpecificLocation( sender: UITapGestureRecognizer ) {
        let controller = ModalViewController()
        controller.delegate = self
        controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext  // モーダルビューの背景透過相当
        controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func modalDidFinished(response: Bool) {
        if response == true {
            goFukuiLocation()
            print("go fukui")
        } else {
            // not to run
        }
        
    }


    
    /// 福井を表示する
    func goFukuiLocation() {
        // set location of JR Fukui Station
        let fukuiLocation = CLLocationCoordinate2DMake(AppSetting.fukuiJrStationLat, AppSetting.fukuiJrStationLng)
        
        self.region = self.mapView.region
        // 0.5 : 56.0km
        self.region.span.latitudeDelta = 0.5
        self.region.span.longitudeDelta = 0.5
        
        self.mapView.setRegion(region, animated:false)
        self.mapView.setCenterCoordinate(fukuiLocation, animated: true)

        
        // TODO : 複数の福井名所をランダムに出せるといいな
        // ボタンを押すまで or 一定時間は、更新をロックする必要ありか。そうしないと、現在地にもどってしまう
    }
    
    /// 位置情報が利用できない場合に、特定の位置に移動。デフォルトは Map 原点のある大西洋が表示
    func goFailSafeLocation(alertTitle: String = NSLocalizedString("Failed to get location", comment: ""), alertMessage: String = NSLocalizedString("Display Fukui Prefecture", comment: "")) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        goFukuiLocation()
    }
    
    
    /// 位置情報のアクセス許可の状況が変わった時に実行
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status{
        case .Restricted:
            print("Error: It is restricted by settings.")
        case .Denied:
            print("Error: It is denied Location Service.")
            goFailSafeLocation()
            manager.stopUpdatingLocation()
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            manager.startUpdatingLocation()
        case .NotDetermined:
            print("Warning: NotDetermined")
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    /// 位置情報取得成功時に実行
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        let location = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        mapView.setCenterCoordinate(location, animated: false)
        
        // GPSの使用を停止する（停止しない限りは、指定間隔で更新）
        manager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// UI言語判断と設定
    func judgeLocalizationUiImage() {
        if AppSetting.langUi == "ja" {
            self.take_pic_button.image = ViewController.take_pic_button_jaImage
            self.collection_button.image = ViewController.collection_button_jaImage
            self.GoFukui.image = ViewController.GoFukui_jaImage
        }
    }

}