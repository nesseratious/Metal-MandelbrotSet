//
//  MacToolbar.swift
//  MandelbrotSetVis
//
//  Created by Denis Esie on 10.06.2021.
//

#if canImport(AppKit)

import AppKit

final class MacToolbar: NSToolbar {
    fileprivate let titles: [String]
    
    init(titles: [String]) {
        self.titles = titles
        super.init(identifier: "Main")
        displayMode = .iconOnly
        delegate = self
    }
}

extension MacToolbar: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.tabs]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .tabs:
            let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier,
                                           titles: titles,
                                           selectionMode: .selectOne,
                                           labels: nil,
                                           target: self,
                                           action: #selector(toolbarSelectionChanged))
            group.setSelected(true, at: 0)
            return group

        default:
            return nil
        }
    }
    
    func toolbarSelectionChanged(_ sender: NSToolbarItemGroup) {
        NotificationCenter.default.post(name: .macToolBarSelectionChanged, object: sender.selectedIndex)
    }
}

extension NSToolbarItem.Identifier {
    static let tabs = Self("com.esie.mandelbrotsetvis.tabs")
}

extension Notification.Name {
    static let macToolBarSelectionChanged = Self("macToolBarSelectionChangeNotification")
}

#endif
