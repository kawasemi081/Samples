//: A Cocoa based Playground to present user interface

import AppKit
import Cocoa
import PlaygroundSupport
import CreateML
/**
pathの指定の仕方もいくつか書き方あるし、、
FileManagerを使うべきところはどこなんだんだろうかとか違いが気になって調べた。
元AppleのSwiftProgrammingGuidの中の人が言及されているのを発見して

```
// https://nshipster.com/filemanager/
When you write an app that interacts with a file system, you don’t know if it’s an HDD or SSD or if it’s formatted with APFS or HFS+ or something else entirely. You don’t even know where the disk is: it could be internal or in a mounted peripheral, it could be network-attached, or maybe floating around somewhere in the cloud.

The best strategy for ensuring that things work across each of the various permutations is to work through FileManager and its related Foundation APIs.
```
*/

func copyFile(filenames: [String], atPath: String, toPath: String) {
    let fileManager = FileManager.default
    let filename = "/Users/midori/workspace/Samples/20191108/MacSingleView.playground/Resources/demo.csv"
    let csvURL = URL(fileURLWithPath: filename)
    
    do {
        /// 大量データを読み込む方法を調べたらこんなOSSがあって、中身を読んでたらじ結構大変そうな感じだった。
        ///  https://github.com/yaslab/CSV.swift
        /// - SeeAlso: https://stackoverflow.com/questions/24152597/how-do-i-open-a-file-in-swift
        /// 大量のデータを読み込むのが問題なのであれば、MLDataTable使えば楽なのかもなと試してみる
        var parsingOptions = MLDataTable.ParsingOptions()
        parsingOptions.skipRows = 0
        parsingOptions.containsHeader = false
        parsingOptions.delimiter = ","
        parsingOptions.lineTerminator = "\n"
        let dataTable = try MLDataTable(contentsOf: csvURL, options: parsingOptions)
        
        dataTable.rows.forEach {
            let csvLine = $0.values.compactMap { $0.stringValue }
            do {
                let savePath = "\(toPath)/\(csvLine[1])"
                let url = URL(fileURLWithPath: savePath)
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

                let fromPath = "\(atPath)/\(csvLine[0])"
                let toPath = "\(savePath)/\(csvLine[0])"
                try fileManager.copyItem(atPath: fromPath, toPath: toPath)
            } catch  {
                print("⭐️: \(error)")
            }
        }
        
        /// https://github.com/yaslab/CSV.swift
    } catch {
        print("⭐️: \(error)")
    }
    print("⭐️Copy is Done⭐️")

}

/// ToDo: 任意の場所から普通に選べるようにする
func savePanel(atPath: String, filenames: [String]) {
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = false
    savePanel.showsTagField = false
    savePanel.message = "保存先フォルダを入力"
    savePanel.begin { (result) -> Void in
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let toPath = savePanel.url else { return }
        let savePath = toPath.path
        
        copyFile(filenames: filenames, atPath: atPath, toPath: savePath)
    }
}

func openPanel() {
    /// - Note: macOSアプリ開発入門にある `runModal()`はplaygroundのこの書き方だと使えなかった → ツールを清書するならちゃんとMacAppProject作る方が ⭕️
    let openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = true // ディレクトリを選択できるか
    openPanel.canCreateDirectories = false // ディレクトリを作成できるか
    openPanel.canChooseFiles = false // ファイルを選択できるか
    openPanel.message = "分類するフォルダを選択"
    openPanel.begin { (result) -> Void in
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let directoryURL = openPanel.url else { return }
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])

            let filenames = contents.compactMap { $0.lastPathComponent }
            savePanel(atPath: directoryURL.path, filenames: filenames)
        } catch {
            print(error)
        }
    }
}


openPanel()

/// playgroundのこの書き方ではDrag&Dropできない
class DraggableView: NSView {

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
        
        if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            for url in urls {
                print(url)
                // 何らかの処理
            }
        }
        return true
    }

}

//-----

//let nibFile = NSNib.Name("MyView")
//var topLevelObjects : NSArray?
//
//Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
//let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }
//
//// Present the view in Playground
//PlaygroundPage.current.liveView = views[0] as! NSView

