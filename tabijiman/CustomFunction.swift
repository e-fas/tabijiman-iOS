//
//  CustomFunction.swift
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

/// リソース内からpng画像を取り出し、NSData形式で返却する
/// - parameter name : 画像の名前(パス)。拡張子[png]あり/なし
/// - returns : NSData形式のpng画像 存在しなければnilを返す。
func getDataFromResource( imageFilename: String ) -> NSData? {
    
    let bundlePath : String = NSBundle.mainBundle().pathForResource( "resource", ofType: "bundle" )!
    let bundle : NSBundle = NSBundle(path: bundlePath)!
    
    let name = imageFilename.componentsSeparatedByString(".").first
    if let imagePath : String = bundle.pathForResource(name, ofType: "png"){
        let fileHandle : NSFileHandle = NSFileHandle(forReadingAtPath: imagePath)!
        let imageData : NSData = fileHandle.readDataToEndOfFile()
        return imageData
    }
    return nil
}

/// images ディレクトリ内の画像ファイルパスを返却。 UIImage(contentsOfFile: ) で利用
/// - parameter imageFilename : 画像の名前 (String)
/// - returns : iOS内の画像ファイル・フルパス (String)
func getPathInImagesDir( imageFilename: String ) -> String {
    return AppSetting.imagesPath + imageFilename
}

/// initTable, getFrameTable 中の画像ファイル名をレスポンス
/// - returns : ２つのテーブルのレスポンスを合成した配列 [Dictionary<String, AnyObject>]
func getImageDicFromDb() -> Array<Dictionary<String, AnyObject>> {
    
    let initData = SQLite.sharedInstance.selectData("init")
    let getFrameData = SQLite.sharedInstance.selectData("getFrame")
    
    var res: Array<Dictionary<String, AnyObject>> = []
    
    // initData : initを最初に (initの数をOffsetとして、後から利用する）
    for item in initData {
        res.append( item )
    }
    
    // getFrameData : getFrameを2番目に
    for item in getFrameData {
        res.append( item )
    }
    
    return res
}