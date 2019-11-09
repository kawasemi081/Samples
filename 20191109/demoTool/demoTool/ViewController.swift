//
//  ViewController.swift
//  demoTool
//
//  Created by MIsono on 2019/11/09.
//  Copyright © 2019 misono. All rights reserved.
//

import Cocoa
/// - Note: `Library not loaded: @rpath/libswiftCreateML.dylib` エラーになる
//import CreateML
import AppKit

class ViewController: NSViewController {

    @IBOutlet weak var openDirectoryButton: NSButton!
    @IBOutlet weak var saveDirectoryButton: NSButton!
    @IBOutlet weak var draggableView: DraggableView!
    
    private var filenames: [String] = []
    private var atPath: String = ""
    private var toPath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func tappedOpenDirectoryButton(_ sender: Any) {
        let openPanel = NSOpenPanel()
           openPanel.canChooseDirectories = true
           openPanel.canCreateDirectories = false
           openPanel.canChooseFiles = false
           openPanel.message = "分類するフォルダを選択"
           openPanel.begin { (result) -> Void in
               guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let directoryURL = openPanel.url else { return }
               do {
                   let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                    self.atPath = directoryURL.path
                    self.filenames = contents.compactMap { $0.lastPathComponent }
               } catch {
                   print(error)
               }
           }
    }
    
    @IBAction func tappedSaveDirectoryButton(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = false
        savePanel.showsTagField = false
        savePanel.message = "保存先フォルダを入力"
        savePanel.begin { (result) -> Void in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let toPath = savePanel.url else { return }
            self.toPath = toPath.path
            
            copyFile(filenames: self.filenames, atPath: self.atPath, toPath: self.toPath, csvPath: self.draggableView.csvFileUrl)
        }
    }
}


func copyFile(filenames: [String], atPath: String, toPath: String, csvPath: String) {
    let fileManager = FileManager.default
    let csvURL = URL(fileURLWithPath: csvPath)
    /// - Note: このOSSを使う方が良い？　　https://github.com/yaslab/CSV.swift
//    do {
//        /// 大量のデータを読み込むのが問題なのであれば、MLDataTable使えば楽なのかもなと試してみる
//        var parsingOptions = MLDataTable.ParsingOptions()
//        parsingOptions.skipRows = 0
//        parsingOptions.containsHeader = false
//        parsingOptions.delimiter = ","
//        parsingOptions.lineTerminator = "\n"
//        let dataTable = try MLDataTable(contentsOf: csvURL, options: parsingOptions)
//
//        dataTable.rows.forEach {
//            let csvLine = $0.values.compactMap { $0.stringValue }
//            do {
//                let savePath = "\(toPath)/\(csvLine[1])"
//                let url = URL(fileURLWithPath: savePath)
//                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//
//                let fromPath = "\(atPath)/\(csvLine[0])"
//                let toPath = "\(savePath)/\(csvLine[0])"
//                try fileManager.copyItem(atPath: fromPath, toPath: toPath)
//            } catch  {
//                print("⭐️: \(error)")
//            }
//        }
        
        
    } catch {
        print("⭐️: \(error)")
    }
    print("⭐️Copy is Done⭐️")

}

class DraggableView: NSView {

    public var csvFileUrl: String = ""

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // 画像をドラッグ＆ドロップで読み込む例
        let pboard = sender.draggingPasteboard
        
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let csvPath = urls.first?.path else { return false }
        csvFileUrl = csvPath
        
        return true
    }
    
    
}
