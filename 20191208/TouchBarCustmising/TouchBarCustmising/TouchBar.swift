//
//  TouchBar.swift
//  TouchBarCustmising
//
//  Created by MIsono on 2019/12/08.
//  Copyright © 2019 misono. All rights reserved.
//

import AppKit

extension NSTouchBar.CustomizationIdentifier {
    static let popoverBar = NSTouchBar.CustomizationIdentifier("com.TouchBarCatalog.popoverBar")
}

extension NSTouchBarItem.Identifier {
    static let scrubberPopover = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.scrubberPopover")
    static let button = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.button")
    static let dismissButton = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.dismissButton")
    static let slider = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.slider")
//    static let label = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.label")
}

