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
        todoList = textView.text.components(separatedBy: "\n").filter { !$0.isEmpty }
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
        let title = todoList.count > 0 ? todoList[increment] : "メモ"
        let identifier = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.button")
        let buttonItem = NSButtonTouchBarItem(identifier: identifier, title: title, target: self, action: #selector(self.touchHandler(_:)))
        buttonItem.customizationLabel = NSLocalizedString("メモ", comment:"")
        
        touchBar.defaultItemIdentifiers.append(identifier)
        touchBar.customizationAllowedItemIdentifiers.append(identifier)
        touchBar.templateItems.insert(buttonItem)
        
        return touchBar
    }

    @objc func touchHandler(_ sender: Any?) {
        guard let buttonItem = sender as? NSButtonTouchBarItem else { return }
        if todoList.count == 0 {
            buttonItem.title = "メモ"
            return
        }

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
