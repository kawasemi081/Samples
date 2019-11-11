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
    
    @IBOutlet weak var message: NSTextField!
    private var atPath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draggableView.wantsLayer = true
        draggableView.layer?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    @IBAction func tappedOpenDirectoryButton(_ sender: Any) {
        /// - Note: MacAppだけ使えるクラス
        /// NSSavePanelよりは設定できるpropertyが多い
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
        /// - Note: MacAppだけ使えるクラス。
        /// フォルダに書き込みがしたいときはこれを使うのとセットで`Target > Capabilityies`でread&writeを指定する
        /// セットし忘れてもちゃんとwarningが出てくれるから初心者でも分かりやすかった
        /// PDFにある`runModal()`メソッドとして使うなら、どのUIボタンが相性が良いのかが分からなかった
        /// MacAppはボタンの種類が多くてちょっと悩ましいなと思う
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = false
        savePanel.showsTagField = false
        savePanel.message = "保存先フォルダを入力"
        savePanel.begin { (result) -> Void in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let toPath = savePanel.url else { return }
            /// - Note: NSTextFieldとかラベル系はiOSなら`label.text = ""`って書くのが当たり前だけど、macAppは`label.stringValue = ""`と書く
            self.saveDirectoryPath.stringValue = toPath.path
        }
    }
    
    @IBAction func sortFiles(_ sender: Any) {
        guard !draggableView.csvFilePath.isEmpty, let atPath = self.atPath, !saveDirectoryPath.stringValue.isEmpty else {
            message.stringValue = draggableView.csvFilePath.isEmpty ? "csvファイルを入れてください" : "フォルダを指定してください"
            return
        }
        
        do {
            let csvString = try String(contentsOfFile: draggableView.csvFilePath, encoding: String.Encoding.utf8)
            let csvLines = csvString.components(separatedBy: .newlines)
            message.stringValue = "分類を開始"
            sort(csvLines: csvLines, atPath: atPath, toPath: saveDirectoryPath.stringValue)
        } catch {
            print(error)
        }

    }
    
    let fileManager = FileManager.default
    private func sort(csvLines: [String], atPath: URL, toPath: String) {
        do {
            /// - Note: 右ペインのDocsをみたら`contentsOfDirectory(at:)`は iOSとMacOSとMac Catalystをサポートしていた
            /// (メソッドにはあまり関係ないけれど) MacOSとMac Catalystが分けて書かれていたので、来年からのAPIは役割が分化していくのかなと少し気になった
            let contents = try fileManager.contentsOfDirectory(at: atPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            csvLines.compactMap { $0.components(separatedBy: ",") }
                .forEach { items in
                    guard !items[0].isEmpty && !items[1].isEmpty,
                        let url = contents.first(where: { $0.lastPathComponent == items[0] }) else { return }
                    
                    let savePath = toPath + "/" + String(items[1])
                    let toPath = URL(fileURLWithPath: savePath)
                    copyItem(atPath: url, directoryUrl: toPath)
            }
            message.stringValue = "分類完了"
  
        } catch  {
            print("⭐️: \(error)")
            message.stringValue = "コンソールログを確認してください"
        }
    }

    private func copyItem(atPath: URL, directoryUrl: URL) {
        do {
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)

            let toPath = directoryUrl.path + "/" + atPath.lastPathComponent
            try fileManager.copyItem(atPath: atPath.path, toPath: toPath)
        } catch  {
            print("⭐️: \(error)")
            message.stringValue = "コンソールログを確認してください"
        }
    }

}
