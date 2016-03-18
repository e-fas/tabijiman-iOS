//
//  FrameCollection.swift
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

class FrameCollection: UITableViewController {
    
    let initData = SQLite.sharedInstance.selectData("init")
    let getFrameData = SQLite.sharedInstance.selectData("getFrame")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Collection", comment: "")
        
        // Clear Text on BackButton on NavigationBar
        let backButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /// Sectionの数を返す
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
    /// Sectionのタイトルを返す
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = [NSLocalizedString("Design", comment: ""), NSLocalizedString("GetDesign", comment: "")]
        return name[section]
    }

    /// Section毎の行の数を返す
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 { return self.initData.count }
        else if section == 1 { return self.getFrameData.count }
        else { return 0 }
    }

    /// 各Cellの設定
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: CustomCell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! CustomCell
        
        if indexPath.section == 0 {
            
            // Configure the cell... from initData
            
            let dic = self.initData[indexPath.row]
            let imageFilename = dic["img"] as? String
            let imageData = getDataFromResource(imageFilename!)!
            cell.frame_image.image = UIImage(data: imageData)!
            
            cell.title.text = dic["name"] as? String
            cell.title.sizeToFit()
            cell.desc.text = dic["desc"] as? String
        }
            
        else if indexPath.section == 1 {
            
            // Configure the cell... from getFrameData
            
            let dic = self.getFrameData[indexPath.row]
            let filename = dic["img"] as! String
            cell.frame_image.image = UIImage(contentsOfFile: getPathInImagesDir(filename))
            
            cell.title.text = dic["name"] as? String
            cell.title.sizeToFit()
            cell.desc.text = dic["desc"] as? String
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("MoreInfo", sender: indexPath)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cellselected: MoreInfo = segue.destinationViewController as! MoreInfo
        cellselected.take_pic_flag = true
        cellselected.frame_get_flag = false
        cellselected.color = "collection"
        cellselected.fromCollectionFlag = true

        switch ( sender as! NSIndexPath ).section {
        case 0:
            cellselected.dic = self.initData[sender!.row]
            cellselected.initFrameFlag = true
            
        case 1:
            cellselected.dic = self.getFrameData[sender!.row]
            cellselected.initFrameFlag = false
            cellselected.fromCollectionFlag = true
            
        default: break
            
        }
    }

}
