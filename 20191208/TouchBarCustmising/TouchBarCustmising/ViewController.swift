//
//  ViewController.swift
//  TouchBarCustmising
//
//  Created by MIsono on 2019/12/06.
//  Copyright © 2019 misono. All rights reserved.
//

import UIKit
import AppKit

class ViewController: UIViewController {
    
    var memos: [String]? = loadText()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = .popoverBar
        memos?.filter { !$0.isEmpty }
            .enumerated().forEach { (offset: Int, element: String) in
                let identifier = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.scrubberPopover" + String(offset))
                let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
                /// - Note: ToolBar > View > Customize Touch Bar で"Open Popover"アイテムのラベルとして表示する文字列
                popoverItem.customizationLabel = NSLocalizedString("メモ\(offset+1)", comment:"")
                popoverItem.collapsedRepresentationLabel = NSLocalizedString(String(element.prefix(5)), comment:"")
                
                popoverItem.popoverTouchBar = PopoverTouchBarSample(memo: element, presentingItem: popoverItem)
                touchBar.defaultItemIdentifiers.append(identifier)
                touchBar.customizationAllowedItemIdentifiers.append(identifier)
                touchBar.templateItems.insert(popoverItem)
        }

        return touchBar
    }

}

private func loadText() -> [String]? {
    guard let path = Bundle.main.path(forResource: "memo", ofType: "txt") else { return nil }
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return content.components(separatedBy: "\n")
    } catch {
        return nil
    }
}
