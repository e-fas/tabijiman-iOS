//
//  extensions.swift
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
import MapKit

private let MERCATOR_OFFSET = 268435456.0         /* (total pixels at zoom level 20) / 2 */
private let MERCATOR_RADIUS = 85445659.44705395 /* MERCATOR_OFFSET / pi */

enum FadeType: NSTimeInterval {
    case
    Normal = 0.2,
    Slow = 1.0
}

extension UIView {
    func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeIn(duration: type.rawValue, completed: completed)
    }
    
    /** For typical purpose, use "public func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeIn(duration duration: NSTimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        alpha = 0
        hidden = false
        UIView.animateWithDuration(duration,
            animations: {
                self.alpha = 1
            }) { finished in
                completed?()
        }
    }
    func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeOut(duration: type.rawValue, completed: completed)
    }
    /** For typical purpose, use "public func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeOut(duration duration: NSTimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        UIView.animateWithDuration(duration
            , animations: {
                self.alpha = 0
            }) { [weak self] finished in
                self?.hidden = true
                self?.alpha = 1
                completed?()
        }
    }
}

extension String {
    
    /// ファイルの存在確認 Found::true, Not Fount::false
    var isExist: Bool {
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(self, isDirectory: nil) { return true }
        
        return false
    }
}

extension NSData {
    
    var sha256: NSData {
        
        var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(self.bytes, CC_LONG(self.length), &hash)
        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        return res
    }
    
}

extension UIColor {
    
    // Twitterの水色を返します
    class func twitterColor()->UIColor{
        return UIColor.rgbColor(0x00ACED)
    }
    
    // Facebookの青色を返します
    class func facebookColor()->UIColor{
        return UIColor.rgbColor(0x305097)
    }
    
    // Lineの緑色を返します
    class func lineColor()->UIColor{
        return UIColor.rgbColor(0x5AE628)
    }
    
    // UIntからUIColorを返します　#FFFFFFのように色を指定できるようになります
    class func rgbColor(rgbValue: UInt) -> UIColor{
        return UIColor(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >>  8) / 255.0,
            blue:  CGFloat( rgbValue & 0x0000FF)        / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func rgb(r r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    class func MainColor() -> UIColor {
        return UIColor.rgb(r: 24, g: 135, b: 208, alpha: 1.0)
    }
}

extension MKMapView {
    
    func originXForLongitude( longitude: Double ) -> Double {
        return round( MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0 )
    }
    
    func originYForLatitude( latitude: Double ) -> Double {
        
        if latitude == 90.0 { return 0 }
        else if latitude == -90.0 { return MERCATOR_OFFSET * 2 }
        else { return round( MERCATOR_OFFSET - MERCATOR_RADIUS * log( ( 1 + sin( latitude * M_PI / 180.0 ) ) / (1 - sin(latitude * M_PI / 180.0))) / 2.0) }
    }
    
    
    func longitudeForOriginX(originX: Double) -> Double {
        return ((round(originX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
    }
    
    func latitudeForOriginY(originY: Double) -> Double {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(originY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
    }
    
    func coordinateSpanWithMapView( zoomLebel zoomLevel: UInt ) -> MKCoordinateRegion {
        
        func pow_i (left:NSNumber, right: NSNumber) -> NSNumber {
            
            return pow(left.doubleValue,right.doubleValue)
        }
        
        let centerPixelX = MKMapView().originXForLongitude(self.userLocation.coordinate.longitude)
        let centerPixelY = MKMapView().originYForLatitude(self.userLocation.coordinate.latitude)
        let zoomExponent = 20 - zoomLevel - 1
        let zoomScale = pow_i(2, right: zoomExponent)
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale.doubleValue
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale.doubleValue
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        let minLng = MKMapView().longitudeForOriginX(topLeftPixelX)
        let maxLng = MKMapView().longitudeForOriginX(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        let minLat = MKMapView().latitudeForOriginY(topLeftPixelY)
        let maxLat = MKMapView().latitudeForOriginY(topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        return MKCoordinateRegionMake(self.userLocation.coordinate, span)
    }
    
    var zoomLevel: Int {
        
        let region: MKCoordinateRegion = self.region
        
        let centerPixelX = MKMapView().originXForLongitude(region.center.longitude)
        let topLeftPixelX = MKMapView().originXForLongitude(region.center.longitude - region.span.longitudeDelta / 2)
        
        let scaledMapWidth = ( centerPixelX - topLeftPixelX ) * 2
        let mapSizeInPixels = self.bounds.size
        let zoomScale = scaledMapWidth / Double(mapSizeInPixels.width)
        let zoomExponent = log( zoomScale ) / log( 2 )
        let zoomLevel = 20 - zoomExponent
        
        return Int(zoomLevel)
    }
}
