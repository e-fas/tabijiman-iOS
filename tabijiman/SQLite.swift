//
//  SQLite.swift
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
import SQLite

final class SQLite: NSObject {
    
    // Prepare Singleton
    static let sharedInstance = SQLite()
    private override init() {
        // something
    }
    
    let place_db = try! Connection(AppSetting.placeDataBase)
    let frame_db = try! Connection(AppSetting.frameDataBase)
    let init_db  = try! Connection(AppSetting.initDataBase)
    let getFrame_db = try! Connection(AppSetting.getFrameDataBase)
    
    // Table : "place" for frame data from odp endpoint
    let placeTable = Table("place")
    let placeId = Expression<Int64>("id")
    let placeName = Expression<String>("name")
    let placeDesc = Expression<String>("desc")
    let placeLat = Expression<Double>("lat")
    let placeLng = Expression<Double>("lng")
    let placeImg = Expression<String>("img")
    let placeAddress = Expression<String>("address")

    // Table : "frame" for frame data from odp endpoint
    let frameTable = Table("frame")
    let frameId = Expression<Int64>("id")
    let frameTitle = Expression<String>("name")
    let frameDesc = Expression<String>("desc")
    let frameLat = Expression<Double>("lat")
    let frameLng = Expression<Double>("lng")
    let frameImg = Expression<String>("img")
    let frameArea = Expression<Double>("area")
    let frameGetFlag = Expression<Bool>("flag")

    // Table : "init" for initial frame data
    let initTable = Table("init")
    let initId = Expression<Int64>("id")
    let initTitle = Expression<String>("name")
    let initDesc = Expression<String>("desc")
    let initLat = Expression<Double>("lat")
    let initLng = Expression<Double>("lng")
    let initImg = Expression<String>("img")
    let initArea = Expression<Double>("area")
    let initGetFlag = Expression<Bool>("flag")
    
    // Table : "getFrame" for frame data which user got
    let getFrameTable = Table("getFrame")
    let getFrameId = Expression<Int64>("id")
    let getFrameTitle = Expression<String>("name")
    let getFrameDesc = Expression<String>("desc")
    let getFrameLat = Expression<Double>("lat")
    let getFrameLng = Expression<Double>("lng")
    let getFrameImg = Expression<String>("img")
    let getFrameGetFlag = Expression<Bool>("flag")

// TODO : enum 導入時には init を initFrame などに名称変更する必要あり
//    enum category {
//        case place
//        case frame
//        case init
//        case getFrame
//    }

    
    func createSqlite() {
        
        print( "onCreate : frame_db >> \(frame_db)\n , place_db >> \(place_db)" )
        
        try! place_db.run(placeTable.create(ifNotExists: true) { t in
            
            t.column(placeId, primaryKey: true)
            t.column(placeName)
            t.column(placeDesc)
            t.column(placeLat)
            t.column(placeLng)
            t.column(placeImg)
            t.column(placeAddress)
            })
        
        try! frame_db.run(frameTable.create(ifNotExists: true) { t in
            
            t.column(frameId, primaryKey: true)
            t.column(frameTitle)
            t.column(frameDesc)
            t.column(frameLat)
            t.column(frameLng)
            t.column(frameImg)
            t.column(frameArea)
            t.column(frameGetFlag)
        })

        try! init_db.run(initTable.create(ifNotExists: true) { t in
            
            t.column(initId, primaryKey: true)
            t.column(initTitle)
            t.column(initDesc)
            t.column(initLat)
            t.column(initLng)
            t.column(initImg)
            t.column(initArea)
            t.column(initGetFlag)
            })
        
        try! getFrame_db.run(getFrameTable.create(ifNotExists: true) { t in
            
            t.column(getFrameId, primaryKey: true)
            t.column(getFrameTitle)
            t.column(getFrameDesc)
            t.column(getFrameLat)
            t.column(getFrameLng)
            t.column(getFrameImg)
            t.column(getFrameGetFlag)
        })
    }
    
    
    func selectData( category: String ) -> Array<Dictionary<String, AnyObject>> {
        
        var results: Array<Dictionary<String, AnyObject>>! = Array<Dictionary<String, AnyObject>>()
        
        switch category {
            
        case "place":
            let query = placeTable.select(
                [placeId, placeAddress, placeName, placeDesc, placeLat, placeLng, placeImg])
            .order(placeId.asc)
            
            for place in try! place_db.prepare(query) {
                
                let res: Dictionary<String, AnyObject> = [
                    "name": place[placeName],
                    "desc": place[placeDesc],
                    "lat" : place[placeLat],
                    "lng" : place[placeLng],
                    "img" : place[placeImg],
                    "address": place[placeAddress]
                ]
                results.append(res)
            }
            return results
            
        case "frame":
            let query = frameTable.select(
                [frameId, frameTitle, frameDesc, frameLat, frameLng, frameImg, frameArea, frameGetFlag])
            .order(frameId.asc)
            
            for frame in try! frame_db.prepare(query) {
                
                let res: Dictionary<String, AnyObject> = [
                    "name": frame[frameTitle],
                    "desc": frame[frameDesc],
                    "lat" : frame[frameLat],
                    "lng" : frame[frameLng],
                    "img" : frame[frameImg],
                    "area": frame[frameArea],
                    "flag": frame[frameGetFlag]
                ]
                results.append(res)
            }
            return results
            
        case "init":
            let query = initTable.select(
                [initId, initTitle, initDesc, initLat, initLng, initImg, initArea, initGetFlag])
            .order(initId.asc)
            
            for inits in try! init_db.prepare(query) {
                
                let res: Dictionary<String, AnyObject> = [
                    "name": inits[initTitle],
                    "desc": inits[initDesc],
                    "lat" : inits[initLat],
                    "lng" : inits[initLng],
                    "img" : inits[initImg],
                    "area": inits[initArea],
                    "flag": inits[initGetFlag]
                ]
                results.append(res)
            }
            return results

        case "getFrame":
            let query = getFrameTable.select(
                [getFrameId, getFrameTitle, getFrameDesc, getFrameLat, getFrameLng, getFrameImg, getFrameGetFlag])
            .order(getFrameId.asc)
            
            for getFrame in try! getFrame_db.prepare(query) {
                
                let res: Dictionary<String, AnyObject> = [
                    "name": getFrame[getFrameTitle],
                    "desc": getFrame[getFrameDesc],
                    "lat" : getFrame[getFrameLat],
                    "lng" : getFrame[getFrameLng],
                    "img" : getFrame[getFrameImg],
                    "flag": getFrame[getFrameGetFlag]
                ]
                results.append(res)
            }
            return results
            
            default: break
        }
        
        return [[:]]
    }

    
    func bulkInsertData( category: String, datass: Array<Dictionary<String, AnyObject>> ) -> Int64 {
        
        switch category {
            
        case "place":
            
            var rowid: Int64 = 0
            try! self.place_db.transaction {

                for datas in datass {

                let name = datas["name"]! as! String
                let desc = datas["desc"]! as! String
                let lat  = datas["lat"]! as! Double
                let lng  = datas["lng"]! as! Double
                
                // SELECT "placeName" FROM "placeTable" where "placeLat == lat && placeLng == lng"
                let query = self.placeTable.select(self.placeName).filter(self.placeLat == lat && self.placeLng == lng)
                if let _ = self.place_db.pluck(query) {
                    #if DEBUG
                        print("pass")
                    #endif
                    // TODO : SPARQLのレスポンスで重複トリプルがある場合の処理
                    // 重複の定義) 完全に位置情報が同じだった場合
                }
                else {
                    let query = self.placeTable.insert(
                        self.placeName <- name,
                        self.placeDesc <- desc,
                        self.placeLat <- lat,
                        self.placeLng <- lng,
                        self.placeImg <- String(datas["img"]!),
                        self.placeAddress <- String(datas["address"]!)
                    )
                    
                    rowid = try self.place_db.run(query)
                    #if DEBUG
                        print("place >> inserted id: \(rowid) with num. of desc: \(desc.characters.count)")
                    #endif
                }
                    
                }
                
            }
            return rowid
        
        case "frame": break
            
        default: break

        }
        return 0
    }
    
    
    func insertData( category: String, datas: Dictionary<String, AnyObject> ) -> Int64 {
        
        switch category {
            
        case "place":
            
            let name = datas["name"]! as! String
            let desc = datas["desc"]! as! String
            let lat  = datas["lat"]! as! Double
            let lng  = datas["lng"]! as! Double

            // SELECT "placeName" FROM "placeTable" where "placeLat == lat && placeLng == lng"
            let query = placeTable.select(placeName).filter(placeLat == lat && placeLng == lng)
            if let _ = place_db.pluck(query) {
                break
                // TODO : SPARQLのレスポンスで重複トリプルがある場合の処理
                // 重複の定義) 完全に位置情報が同じだった場合
            }
            else {
                let insert = placeTable.insert(
                    placeName <- name,
                    placeDesc <- desc,
                    placeLat <- lat,
                    placeLng <- lng,
                    placeImg <- String(datas["img"]!),
                    placeAddress <- String(datas["address"]!)
                )
                
                do {
                    let rowid = try place_db.run(insert)
                    print("place >> inserted id: \(rowid) with num. of desc: \(desc.characters.count)")
                    return rowid
                } catch {
                    print("place >> insertion failed: \(error)")
                }
            }

        case "frame":
            
            // SELECT "frameTitle" FROM "frameTable"
            let query = frameTable.select(frameTitle).filter(frameTitle == datas["name"]! as! String)
            
            if let _ = frame_db.pluck(query) { break }
            else {
                
                let insert = frameTable.insert(
                    frameTitle <- String(datas["name"]!),
                    frameDesc <- String(datas["desc"]!),
                    frameLat <- Double(datas["lat"]! as! Double),
                    frameLng <- Double(datas["lng"]! as! Double),
                    frameImg <- String(datas["img"]!.absoluteString),
                    frameArea <- Double(datas["area"]! as! Double),
                    frameGetFlag <- Bool(datas["flag"]! as! Bool)
                )
                
                do {
                    let rowid = try frame_db.run(insert)
                    print("frame >> inserted id: \(rowid)")
                    return rowid
                } catch {
                    print("frame >> insertion failed: \(error)")
                }
            }
            
        case "init":
            
            // SELECT "initTitle" FROM "initTable"
            let query = initTable.select(initTitle).filter(initLat == datas["lat"]! as! Double)
            
            if let _ = init_db.pluck(query) { break }
            else {
                
                let insert = initTable.insert(
                    initTitle <- "\(datas["name"]!)",
                    initDesc <- "\(datas["desc"]!)",
                    initLat <- Double(datas["lat"]! as! Double),
                    initLng <- Double(datas["lng"]! as! Double),
                    initImg <- String(datas["img"]! as! String),
                    initArea <- Double(datas["area"]! as! Double),
                    initGetFlag <- Bool(datas["flag"]! as! Bool)
                )
                
                do {
                    let rowid = try init_db.run(insert)
                    print("init >> inserted id: \(rowid)")
                    return rowid
                } catch {
                    print("init >> insertion failed: \(error)")
                }
            }

        case "getFrame":
            
            let name = datas["name"]! as! String
            let desc = datas["desc"]! as! String
            let lat  = datas["lat"]! as! Double
            let lng  = datas["lng"]! as! Double

            // SELECT "getFrameTitle" FROM "getFrameTable"
            let query = getFrameTable.select(getFrameTitle).filter(getFrameTitle == name && getFrameLat == lat)
            
            if let _ = getFrame_db.pluck(query) { break }
            else {
                
                let insert = getFrameTable.insert(
                    getFrameTitle <- name,
                    getFrameDesc <- desc,
                    getFrameLat <- lat,
                    getFrameLng <- lng,
                    getFrameImg <- String(datas["img"]! as! String),
                    getFrameGetFlag <- false /* Bool(datas["flag"]! as! Bool) */
                )
                
                do {
                    let rowid = try getFrame_db.run(insert)
                    print("getFrame >> inserted id: \(rowid)")
                    return rowid
                } catch {
                    print("getFrame >> insertion failed: \(error)")
                }
            }
            
        default: break
        }
        
        return 0
        
    }
    
    
    func enableGetFlag(name: String) {
        
        let object = self.frameTable.filter(frameTitle == name)
        try! frame_db.run(object.update(frameGetFlag <- true))
        selectData("frame")
    }
    
    
    func searchWithQuery( imgName: String, category: String, imgTag: Int64 ) -> Dictionary<String, AnyObject> {
        
        switch category {
            
        case "init":
            let query = initTable.select(
                [initId, initTitle, initDesc, initLat, initLng, initArea, initImg, initGetFlag]).filter(initImg == imgName)
            let res = init_db.pluck(query)
            
            print( res!.get(initTitle) )
            
            let dic: Dictionary<String, AnyObject> = [
                
                "name": res!.get(initTitle),
                "lat": res!.get(initLat),
                "lng": res!.get(initLng)
            ]
            
            return dic
        
        case "getFrame":
            let query = getFrameTable.select(
                [getFrameId, getFrameTitle, getFrameDesc, getFrameLat, getFrameLng, getFrameImg, getFrameGetFlag])
            
            for frame in try! getFrame_db.prepare(query) {
                
                if frame[getFrameTitle] == imgName {
                    
                    print(frame[getFrameTitle])
                    
                    let dic: Dictionary<String, AnyObject> = [
                        
                        "name": frame[getFrameTitle],
                        "lat": frame[getFrameLat],
                        "lng": frame[getFrameLng]
                    ]
                    
                    return dic
                }
            }

        default: break
        }
        
        return Dictionary()
    }
    
    func count( category: String ) -> Int {
        switch category {

        case "init":
            var count = 0
            count = init_db.scalar(initTable.count)
            return count
        default:
            return 0
        }
    }

    func truncateTable( category: String ) {
        
        switch category {
            
        case "place":
            do {
                try place_db.run(placeTable.delete())
            } catch {
                print("fail to truncate \(category)")
            }

        case "frame":
            do {
                try frame_db.run(frameTable.delete())
            } catch {
                print("fail to truncate \(category)")
            }

        case "init":
            do {
                try init_db.run(initTable.delete())
            } catch {
                print("fail to truncate \(category)")
            }

        case "getFrame":
            do {
                try getFrame_db.run(getFrameTable.delete())
            } catch {
                print("fail to truncate \(category)")
            }

        default:
            break
        }
    }
    
    func dropSqlite() {
        
        print( "onDrop : frame_db >> \(frame_db)\n , place_db >> \(place_db)" )
        
        try! place_db.run(placeTable.drop(ifExists: true))
        
        try! frame_db.run(frameTable.drop(ifExists: true))
        
        try! init_db.run(initTable.drop(ifExists: true))
        
        try! getFrame_db.run(getFrameTable.drop(ifExists: true))
    }
}