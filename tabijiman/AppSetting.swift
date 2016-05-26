//
//  AppSetting.swift
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

import Foundation

// tabijiman アプリ View共通設定をまとめるクラス
// 方向性として static let を利用した クラス変数 としてまとめていく
final class AppSetting {
    static var startUp_flag: Bool? = false

    static let shareTag = "#tabijiman"  // シェア時に追加するハッシュタグ
    
    /// debug用フラグ
    /// false - ファイルの書き込みディレクトリが Library  に
    /// true  - ファイルの書き込みディレクトリが Document に
    static let debug: Bool = false
    static let documentPath =
    debug ? NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        : NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
    static let imagesPath = documentPath + "/images/"
    
    // Db file Path
    static let placeDataBase = documentPath + "/place.sqlite3"
    static let frameDataBase = documentPath + "/frame.sqlite3"
    static let initDataBase = documentPath + "/init.sqlite3"
    static let getFrameDataBase = documentPath + "/getFrame.sqlite3"

    
    // lang
    static let preferredLanguage: Array<String> = {
        let languages = NSLocale.preferredLanguages()  // like "ja-JP", "en", "en-JP", "ja-US", "zh-Hans" ...
        let firstLang = (languages.first! as String).characters.split("-").map{ String($0) }  // like Optional(["ja", "JP"])
        return firstLang
    }()

    // SPARQL クエリで使う言語タグ用
    static var langSparql: String {
        get {
            let lang = preferredLanguage.first!
            let langKeywords = preferredLanguage
            let separeter = "-"

//            print(langKeywords)
            
            switch lang {
            case "ja":
                return lang  // ja  (not ja-JP OR ja-US)
            case "ko":
                return lang  // ko
            case "zh":
                let second = langKeywords[1]
                if second == "HK" || second == "TW" {
                    return "zh-Hant"  // zh-HK OR zh-TW の場合は zh-Hant　をレスポンス
                } else {
                    return lang + separeter + langKeywords[1]  // zh-Hans (中国語簡体字) OR zh-Hant (中国語繁体字)
                }
            case "pt":
                return lang  // pt  (not pt-PT)
            default:
                return "en"  // その他の言語はすべて
            }
        }
    }

    // アプリ画面UI用
    static var langUi: String {
        get {
            let lang = preferredLanguage.first!  // only need "ja" or "en" or others
            
            switch lang {
            case "ja":
                return lang
            default:
                return "en"  // ja 以外はすべて
            }
        }
    }
    
    // SPARQL
    static let SPARQL_endpoint = "http://sparql.odp.jig.jp/api/v1/sparql"
    static let SPARQL_get_param = "?output=json&query="
    static let minDescriptionString = 10  // 最低文字数を設定
    
    // 観光情報を取得　（言語タグなし、住所をOption[任意]として指定。';' 記法で主語省略）
    static let SPARQL_query_place =
    "select ?s ?name ?cat ?lat ?lng ?add ?name ?desc ?img {"
        + "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#種別> ?cat;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lng;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat;"
        + "<http://www.w3.org/2000/01/rdf-schema#label> ?name;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#説明> ?desc;"
        + "<http://schema.org/image> ?img;"
        + "OPTIONAL {"
        +     "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        +     "<http://purl.org/jrrk#address> ?add; }"
        + "FILTER ( lang(?name) = \"" + String(langSparql) + "\" )"
        + "FILTER ( lang(?desc) = \"" + String(langSparql) + "\" )"
        + "FILTER ( STRLEN(?desc) > " + String(minDescriptionString) + " )"
        + "}"

    // 観光情報を取得　（言語タグなし、住所なし、画像情報をOption[任意]として指定）
    static let SPARQL_query_place_imgOption =
    "select ?s ?name ?cat ?lat ?lng ?add ?name ?desc ?img {"
        + "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#種別> ?cat;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lng;"
        + "<http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat;"
        + "<http://www.w3.org/2000/01/rdf-schema#label> ?name;"
        + "<http://imi.ipa.go.jp/ns/core/rdf#説明> ?desc;"
        + "OPTIONAL {"
        +     "?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/jrrk#CivicPOI>;"
        +     "<http://schema.org/image> ?img; }"
        + "}"
    
    // カオハメフレームを取得　（言語タグ でフィルタあり、Prefix表記。 '.' 記法で主語必須）
    static let SPARQL_prefix =
    "prefix geo:   <http://www.w3.org/2003/01/geo/wgs84_pos#>"
        + "prefix odp:   <http://odp.jig.jp/odp/1.0#>"
        + "prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
        + "prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#>"
        + "prefix schema: <http://schema.org/>"
    
    static let SPARQL_query_frame = SPARQL_prefix
    + "select ?s ?name ?desc ?img ?scope ?center ?lat ?lng ?rads ?rad ?unit {"
        + "?s rdf:type odp:ComicForeground  ."
        + "?s rdfs:label ?name . FILTER ( lang(?name) = \"".stringByAppendingString(langSparql) + "\" )"
        + "?s schema:description ?desc . FILTER ( lang(?desc) = \"".stringByAppendingString(langSparql) + "\" )"
        + "?s schema:image ?img ."
        + "?s odp:scope ?scope ."
        + "?scope odp:midpoint ?center ."
        + "?center geo:lat ?lat ."
        + "?center geo:long ?lng ."
        + "?scope odp:radius ?rads ."
        + "?rads rdf:value ?rad ."
        + "?rads odp:unit ?unit . }"



    // InitFrameData.plist
    static let initFrameDataPath = NSBundle.mainBundle().pathForResource("InitFrameData", ofType:"plist" )
//    static let numInitFrame: Int = 4  // Number of InitFrames
//    static let initFileName = ["frame_nishiyama","frame_fukui_juratic","frame_fukui_asuwa","frame_mizushima"]

    static let ud = NSUserDefaults.standardUserDefaults()
    
    
    static private let key_udPlaceHash: String = "placeHash"
    /// Hash for place
    static var udPlaceHash : NSData {
        get {
            if ud.objectForKey(key_udPlaceHash) != nil {
                let data: NSData = ud.objectForKey(key_udPlaceHash) as! NSData
                return data
            }
            let iniString = "Initial String data in PlaceHash"
            let iniData: NSData = iniString.dataUsingEncoding(NSUTF8StringEncoding)!
            return iniData
        }
        set (newValue) {
            ud.setObject(newValue, forKey: key_udPlaceHash)
        }
    }
    
    static private let key_udFrameHash: String = "frameHash"
    /// Hash for frame
    static var udFrameHash : NSData {
        get {
            if ud.objectForKey(key_udFrameHash) != nil {
                let data: NSData = ud.objectForKey(key_udFrameHash) as! NSData
                return data
            }
            let iniString = "Initial String data in FrameHash"
            let iniData: NSData = iniString.dataUsingEncoding(NSUTF8StringEncoding)!
            return iniData
        }
        set (newValue) {
            ud.setObject(newValue, forKey: key_udFrameHash)
        }
    }

    static private let key_udInitFrameHash: String = "initFrameHash"
    /// Hash for initFrame
    static var udInitFrameHash : NSData {
        get {
            if ud.objectForKey(key_udInitFrameHash) != nil {
                let data: NSData = ud.objectForKey(key_udInitFrameHash) as! NSData
                return data
            }
            let iniString = "Initial String data in InitFrameHash"
            let iniData: NSData = iniString.dataUsingEncoding(NSUTF8StringEncoding)!
            return iniData
        }
        set (newValue) {
            ud.setObject(newValue, forKey: key_udInitFrameHash)
        }
    }

    
    //
    static let fukuiJrStationLat: Double = 36.061959
    static let fukuiJrStationLng: Double = 136.222986
    static let boarderOfDistance: Double = 100000  // (単位 m) 福井との距離のボーダー
    static let boarderOfCounter:  Int = 20  // この回数起動に1回 Goto福井を出す
    
    static private let key_udDbSchemaVer: String = "DbSchemaVer"
    /// manage db Schema Version (AppVer 1.0.x has 0)
    static var udDbSchemaVer : Int {
        get {
            let num: Int = ud.integerForKey(key_udDbSchemaVer)
            return num
        }
        set (newValue) {
            ud.setInteger(newValue, forKey: key_udDbSchemaVer)
        }
    }
    
    static private let key_udCountRun: String = "CountRun"
    /// Counter for Goto Fukui
    static var udCountRun : Int {
        get {
            let num:Int = ud.integerForKey(key_udCountRun)
//            print("in if: \(num)")
            return num
        }
    }
    /// Incriment Counter for Goto Fukui
    static func inc_udCountRun() {
        var num: Int = ud.integerForKey(key_udCountRun)
//        print("current num \(num)")
        num = num + 1
        ud.setInteger(num, forKey: key_udCountRun)
//        print("count up \(num)")
    }
    
    
}
