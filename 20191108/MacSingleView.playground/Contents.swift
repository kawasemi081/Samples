//: A Cocoa based Playground to present user interface

import AppKit
import Cocoa
import PlaygroundSupport

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
func copyItem(csvLines: [String], filenames: [String], atPath: String, toPath: String) {
    /// - Note: 機械学習のような物凄い行数のcsvはStringとして扱うで合ってるのかなぁ、と分からなくて書いてて不安になった
    let fileManager = FileManager.default
    csvLines.forEach {
        let item = $0.components(separatedBy: ",")
        guard filenames.contains(item[0]) else { return }
        
        do {
            let savePath = "\(toPath)/\(item[1])"
            let url = URL(fileURLWithPath: savePath)
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            let fromPath = "\(atPath)/\(item[0])"
            let toPath = "\(savePath)/\(item[0])"
            try fileManager.copyItem(atPath: fromPath, toPath: toPath)

        } catch  {
            print("⭐️: \(error)")
        }
    }
    
    print("⭐️Copy is Done⭐️")
}

/// ToDo: 任意の場所から普通に選べるようにする
func savePanel(csvLines: [String], atPath: String, filenames: [String]) {
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = false
    savePanel.showsTagField = false
    savePanel.begin { (result) -> Void in
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let toPath = savePanel.url else { return }
        let savePath = toPath.path
        
        /// - Note: ６件ぐらいのサンプルだとループの中でやって良いのか判断できなかった　(もっと良いやり方あるか調査をToDoにした方が良い？？)
        copyItem(csvLines: csvLines, filenames: filenames, atPath: atPath, toPath: savePath)
    }
}

func openPanel(csvLines: [String]) {
    /// - Note: macOSアプリ開発入門にある `runModal()`はplaygroundのこの書き方だと使えなかった → ツールを清書するならちゃんとMacAppProject作る方が ⭕️
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = true // 複数ファイルの選択を許すか
    openPanel.canChooseDirectories = true // ディレクトリを選択できるか
    openPanel.canCreateDirectories = false // ディレクトリを作成できるか
    openPanel.canChooseFiles = true // ファイルを選択できるか
    /// - Note: ファイル種別はmacOSアプリ開発入門にある下記の指定方法とどちらが良いかとか、usecaseが自分の中では曖昧。。//NSImage.imageTypes
    ///  `["jpg", "jpeg", "JPG", "JPEG", "png", "PNG", "tiff", "TIFF", "tif", "TIF"]`
    /// - SeeAlso: https://developer.apple.com/documentation/appkit/nsimage/1519988-imagetypes
    openPanel.allowedFileTypes = NSImage.imageTypes // 選択できるファイル種別

    openPanel.begin { (result) -> Void in
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let directoryURL = openPanel.directoryURL else { return }
        let filenames = openPanel.urls.compactMap { $0.lastPathComponent }

        savePanel(csvLines: csvLines, atPath: directoryURL.path, filenames: filenames)
    }
}

do {
    /// ToDo: 任意の場所からDrag&Dropする
    let csvString = try String(contentsOfFile: "/Users/midori/workspace/MacSingleView.playground/Resources/demo.csv", encoding: String.Encoding.utf8)
    let csvLines = csvString.components(separatedBy: .newlines)
    /// - Note: csvにタイトル有るなら必要
    //    csvLines.removeFirst()

    /// - Note: 下書き用なのでとりあえず保存先Dirを選択するのがわかるようにNSSavePanelを利用
    /// サンドボックスより外のフォルダ階層を指定することをミニマムにしたいと思ったら、Finderを出してユーザーが選択しないとセキュリティ的にダメ だとPDF読んで学んだ
    openPanel(csvLines: csvLines)
} catch {
    print(error)
}






//-----

let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
PlaygroundPage.current.liveView = views[0] as! NSView

