//
//  ViewController.swift
//  demoTool
//
//  Created by MIsono on 2019/11/09.
//  Copyright © 2019 misono. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var openDirectoryButton: NSButton!
    @IBOutlet weak var saveDirectoryButton: NSButton!
    @IBOutlet weak var sortFileButton: NSButton!
    @IBOutlet weak var draggableView: DraggableView!
    
    @IBOutlet weak var openDirectoryPath: NSTextField!
    @IBOutlet weak var saveDirectoryPath: NSTextField!
    
    private var atPath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draggableView.wantsLayer = true
        draggableView.layer?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    @IBAction func tappedOpenDirectoryButton(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.message = "分類するフォルダを選択"
        openPanel.begin { (result) -> Void in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let directoryURL = openPanel.url else { return }
            self.atPath = directoryURL
            self.openDirectoryPath.stringValue = directoryURL.path
        }
    }
    
    @IBAction func tappedSaveDirectoryButton(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = false
        savePanel.showsTagField = false
        savePanel.message = "保存先フォルダを入力"
        savePanel.begin { (result) -> Void in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let toPath = savePanel.url else { return }
    
            self.saveDirectoryPath.stringValue = toPath.path
        }
    }
    
    @IBAction func sortFiles(_ sender: Any) {
        guard !draggableView.csvFilePath.isEmpty, let atPath = self.atPath, !saveDirectoryPath.stringValue.isEmpty else { return }
        
        do {
            let csvString = try String(contentsOfFile: draggableView.csvFilePath, encoding: String.Encoding.utf8)
            let csvLines = csvString.components(separatedBy: .newlines)

            sort(csvLines: csvLines, atPath: atPath, toPath: saveDirectoryPath.stringValue)
        } catch {
            print(error)
        }

    }
}

let fileManager = FileManager.default
private func sort(csvLines: [String], atPath: URL, toPath: String) {
    do {
        let contents = try fileManager.contentsOfDirectory(at: atPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        csvLines.compactMap { $0.components(separatedBy: ",") }
            .forEach { items in
                guard !items[0].isEmpty && !items[1].isEmpty,
                    let url = contents.first(where: { $0.lastPathComponent == items[0] }) else { return }
                
                let savePath = toPath + "/" + String(items[1])
                let toPath = URL(fileURLWithPath: savePath)
                copyItem(atPath: url, directoryUrl: toPath)
        }

    } catch  {
        print("⭐️: \(error)")
    }
}

private func copyItem(atPath: URL, directoryUrl: URL) {
    do {
        try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)

        let toPath = directoryUrl.path + "/" + atPath.lastPathComponent
        try fileManager.copyItem(atPath: atPath.path, toPath: toPath)
    } catch  {
        print("⭐️: \(error)")
    }
}
