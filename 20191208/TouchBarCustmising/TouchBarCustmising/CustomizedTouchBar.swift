//
//  CustomizedTouchBar.swift
//  TouchBarCustmising
//
//  Created by MIsono on 2019/12/08.
//  Copyright © 2019 misono. All rights reserved.
//

import AppKit
import UIKit

class PopoverTouchBarSample: NSTouchBar {

    var memo: String?
    var presentingItem: NSPopoverTouchBarItem?
    
    override init() {
        super.init()
        
        delegate = self
        defaultItemIdentifiers = [.button]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(memo: String? = nil, presentingItem: NSPopoverTouchBarItem? = nil, forPressAndHold: Bool = false) {
        self.init()

        self.memo = memo
        self.presentingItem = presentingItem
    }
    
    @objc
    func actionHandler(_ sender: Any?) {
        print("\(#function) is called")
    }
}

/**
 - Important:
 Mac Catalystでは、NSCustomTouchBarItemとNSScrubberは使えない❌
 NSScrubberDelegateもサポート対象外❌
 */
extension PopoverTouchBarSample: NSTouchBarDelegate {
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        guard let memo = self.memo else { return nil }
        
        
        let buttonItem = NSButtonTouchBarItem(identifier: identifier, title: memo, target: self, action: #selector(PopoverTouchBarSample.actionHandler(_:)))

        return buttonItem
    }
}
