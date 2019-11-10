//
//  DraggableView.swift
//  demoTool
//
//  Created by MIsono on 2019/11/10.
//  Copyright © 2019 misono. All rights reserved.
//

import Cocoa

class DraggableView: NSView {

    /**
    - Note:iOSとは違うなと感じたところ
      - 背景色は変えられない(PDFが書かれたときから変更なし)
      - NSViewにIBOutletが使えない
      - NSTextFieldの折り返し行数をstoryboardで指定できない
      - storyboard上でできるUIUXの属性がiOSより少ない
     */
    public var csvFilePath: String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let csvPath = urls.first else { return false }

        csvFilePath = csvPath.path
        print("csvfile: " + csvPath.path)
        
        return true
    }
    
}
