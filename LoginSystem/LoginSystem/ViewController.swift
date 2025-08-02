//
//  ViewController.swift
//  LoginSystem
//
//  Created by nika razmadze on 02.08.25.
//

import UIKit

final class SearchViewController: UIViewController {
    private let searchBar  = UISearchBar()
    private let tableView  = UITableView()
    
    private var history: [String] = []
    private var results: [String] = []   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        searchBar.placeholder = "Search music..."
        navigationItem.titleView = searchBar
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        history = UserDefaults.standard.stringArray(forKey: "searches") ?? []
    }
    
    private func save(term: String) {
        if let idx = history.firstIndex(of: term) { history.remove(at: idx) }
        history.insert(term, at: 0)
        if history.count > 5 { history.removeLast() }
        UserDefaults.standard.set(history, forKey: "searches")
    }
    
    private func search(term: String) {
        save(term: term)
        let urlStr = "https://itunes.apple.com/search?media=music&limit=10&term=\(term)"
        guard let url = URL(string: urlStr) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["results"] as? [[String: Any]] else { return }
            
            self.results = items.compactMap { $0["trackName"] as? String }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text, !term.isEmpty else { return }
        search(term: term)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.isEmpty ? history.count : results.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if results.isEmpty {
            cell.textLabel?.text = history[indexPath.row]
        } else {
            cell.textLabel?.text = results[indexPath.row]
        }
        return cell
    }
}

