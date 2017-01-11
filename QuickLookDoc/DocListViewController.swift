//
//  DocListViewController.swift
//  QuickLookDoc
//
//  Created by txx on 17/1/11.
//  Copyright © 2017年 txx. All rights reserved.
//

import UIKit
import Foundation
import QuickLook

class DocListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    /// 文件列表
    let docs = ["AppCoda-PDF.pdf", "AppCoda-Pages.pages", "AppCoda-Word.docx", "AppCoda-Keynote.key", "AppCoda-Text.txt", "AppCoda-Image.jpeg"]
    
    /// 文件本地路径或网上路径
    var docURLs = [NSURL]()
    
    /// 预览的控制器
    let quickLookController = QLPreviewController()
    
    /// 重用标识符
    let CellReuseId = "cellReuseId";
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "doc list"
        self.automaticallyAdjustsScrollViewInsets = false
        prepareFileURLs()

        configTableView()
        configQuickLookController()
        
        
    }
    
    func prepareFileURLs() {
        docURLs = docs.map({ (itemStr) -> NSURL in
            let docParts = itemStr.components(separatedBy: ".")
            let docPath = Bundle.main.path(forResource: docParts[0], ofType: docParts[1])
            
            if (docPath != nil) {
                let isFileExist = FileManager.default.fileExists(atPath: docPath!)
                if isFileExist
                {
                    return URL.init(fileURLWithPath: docPath!) as NSURL
                }
            }
            return NSURL()
        })
    }
    func configQuickLookController() {
        quickLookController.delegate = self ;
        quickLookController.dataSource = self ;
    }
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
extension DocListViewController:UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docs.count ;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId)
        cell?.textLabel?.text = docs[indexPath.row]
        
        return cell!;
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        
        let isCanPreview = QLPreviewController.canPreview(docURLs[indexPath.row])
        
        if isCanPreview
        {
            quickLookController.currentPreviewItemIndex = indexPath.row
            self.navigationController?.pushViewController(quickLookController, animated: true)
        }
        
    }
}
extension DocListViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    
    // Delegate
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        print("The Preview Controller will be dismissed.")
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        print("The Preview Controller has been dismissed.")
    }
    
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        if item as! NSURL == docURLs[0] {
            return true
        }
        else {
            print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
    
    // DataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return docURLs.count ;
    }
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem{
        return docURLs[index]
    }
}
