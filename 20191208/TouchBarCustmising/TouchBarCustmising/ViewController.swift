//
//  ViewController.swift
//  TouchBarCustmising
//
//  Created by MIsono on 2019/12/06.
//  Copyright © 2019 misono. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var increment: Int = 0
    var todoList: [String] = loadText() {
        didSet {
            textView.text = todoList.joined(separator: "\n")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = todoList.joined(separator: "\n")
        let controller = UIDocumentPickerViewController.init(documentTypes: ["public.txt"], in: .open)
        controller.delegate = self;
        controller.allowsMultipleSelection = false;
        self.present(controller, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        do {
            let content = try String(contentsOfFile: url.path, encoding: .utf8)
            let newList = content.components(separatedBy: "\n").filter { !$0.isEmpty }
            guard newList.count > 0 else { return }

            self.todoList = newList
            self.increment = 0
            /// - Note: `ViewController.makeTouchBar()`を呼びたいけれど呼べない
        } catch {
            print("Oops! faild to read")
        }
    }
    
    @IBAction func saveTodoList(_ sender: Any) {
        let todoList = textView.text.components(separatedBy: "\n").filter { !$0.isEmpty }
        save(todoList: todoList)
    }
}



#if targetEnvironment(macCatalyst)
import AppKit
/// - Note:ビルドターゲットをiPadにするとエラーになるので`TouchBar.swift`のように別ファイルにして
/// 　　　　CompireSourcesのplatformをmacOSにしてしまう方が可読性という点では良いかも。
extension ViewController {

    override func makeTouchBar() -> NSTouchBar? {
        return makeButtonItems()
    }

    private func makeButtonItems() -> NSTouchBar {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = .customViewBar
        
        let identifier = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.button")
        let buttonItem = NSButtonTouchBarItem(identifier: identifier, title: todoList[increment], target: self, action: #selector(self.touchHandler(_:)))
        buttonItem.customizationLabel = NSLocalizedString("メモ", comment:"")
        
        touchBar.defaultItemIdentifiers.append(identifier)
        touchBar.customizationAllowedItemIdentifiers.append(identifier)
        touchBar.templateItems.insert(buttonItem)
        
        return touchBar
    }

    private func makePopoverItems() -> NSTouchBar {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = .customViewBar
        
        todoList.filter { !$0.isEmpty }
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

    @objc func touchHandler(_ sender: Any?) {
        print("\(#function) is called")
        guard let buttonItem = sender as? NSButtonTouchBarItem else { return }
        
        if increment + 1 < todoList.count {
            increment += 1
        } else {
            increment = 0
        }

        buttonItem.title = todoList[increment]
    }

}
#endif

let userDefaults = UserDefaults.standard
private func loadText() -> [String] {
    guard let todoList = userDefaults.stringArray(forKey: "TodoList")  else { return [] }
    return todoList.filter { !$0.isEmpty }
}

private func save(todoList: [String]) {
    userDefaults.set(todoList, forKey: "TodoList")
}
