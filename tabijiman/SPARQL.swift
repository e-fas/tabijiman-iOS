//
//  SPARQL.swift
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
import Alamofire
import SwiftyJSON

protocol SPARQLDelegate {
    func parsed(dic_data: Array<Dictionary<String, AnyObject>>, category: String)
}

class SPARQL: NSObject {

    var data: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
    var category: String = String()
    var temp: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    var delegate: SPARQLDelegate! = nil
    
    func query(query: String, category: String) {
        
        // will be like "http://sparql.odp.jig.jp/api/v1/sparql?output=json&query=select..."
        let url = AppSetting.SPARQL_endpoint + AppSetting.SPARQL_get_param
            + query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let request = NSMutableURLRequest(URL: NSURL(string: url)! , cachePolicy:.ReloadIgnoringLocalCacheData, timeoutInterval:5.0)
        
        if category == "place" {
        
            Alamofire.request(.GET, request)
                .validate(statusCode: 200..<300)
                .response { ( request, response, data, error ) in
                    
                    if error == nil {
                        let jsons = JSON(data: data!)
                        
                        for (_, json):(String, JSON) in jsons["results"]["bindings"] {
                            
                            self.temp = [:]
                            
                            self.temp["name"] = json["name"]["value"].stringValue
                            self.temp["desc"] = json["desc"]["value"].stringValue
                            self.temp["address"] = json["add"]["value"].stringValue
                            self.temp["lat"]  = json["lat"]["value"].doubleValue
                            self.temp["lng"]  = json["lng"]["value"].doubleValue
                            self.temp["img"]  = NSURL(string: json["img"]["value"].stringValue)
                            
                            self.data.append(self.temp)
                        }
                        
                        self.delegate.parsed(self.data, category: category)
                    }
                    else {
                        // HTTP request failed
                        print(error)
                    }
            }
        }
        else if category == "frame" {
            
            Alamofire.request(.GET, request)
                .validate(statusCode: 200..<300)
                .response { ( request, response, data, error ) in
                    
                    if error == nil {
                        let jsons = JSON(data: data!)
                        
                        for (_, json):(String, JSON) in jsons["results"]["bindings"] {
                            
                            self.temp = [:]
                            
                            self.temp["name"] = json["name"]["value"].stringValue
                            self.temp["desc"] = json["desc"]["value"].stringValue
                            self.temp["img"]  = NSURL(string: json["img"]["value"].stringValue)
                            self.temp["lat"]  = json["lat"]["value"].doubleValue
                            self.temp["lng"]  = json["lng"]["value"].doubleValue
                            self.temp["area"] = json["rad"]["value"].intValue
                            self.temp["flag"] = false
                            
                            self.data.append(self.temp)
                        }
                        
                        self.delegate.parsed(self.data, category: category)
                    } else {
                        // HTTP request failed
                        print(error)
                    }
            }
        }
    }
}
