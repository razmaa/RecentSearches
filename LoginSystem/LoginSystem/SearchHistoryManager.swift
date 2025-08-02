//
//  SearchHistoryManager.swift
//  LoginSystem
//
//  Created by nika razmadze on 02.08.25.
//

import Foundation

final class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    
    private let key       = "searchHistory"
    private let maxItems  = 5
    private let defaults  : UserDefaults
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: Public API
    func history() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }
    
    func add(_ term: String) {
        var items = history()
        
        if let idx = items.firstIndex(where: { $0.caseInsensitiveCompare(term) == .orderedSame }) {
            items.remove(at: idx)
        }
        
        items.insert(term, at: 0)
        
        if items.count > maxItems {              
            items.removeLast(items.count - maxItems)
        }
        defaults.set(items, forKey: key)
    }
    
    func clear() { defaults.removeObject(forKey: key) }
}
