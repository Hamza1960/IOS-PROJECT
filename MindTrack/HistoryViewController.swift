//
//  HistoryViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Screen 4: Journal History
//  Displays a scrollable list of past mood entries in a UITableView.
//  Supports swipe-to-delete and tap to view detail.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var entries: [MoodEntry] = []
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "EntryCell")
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No journal entries yet.\nTap \"Log Today's Mood\" to get started! 📝"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEntries()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }
    
    private func loadEntries() {
        entries = DataManager.shared.fetchAllEntries()
        tableView.reloadData()
        emptyLabel.isHidden = !entries.isEmpty
        tableView.isHidden = entries.isEmpty
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)
        let entry = entries[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let dateStr = dateFormatter.string(from: entry.date ?? Date())
        
        let moodEmoji = DataManager.shared.moodEmoji(for: entry.mood)
        let moodLabel = DataManager.shared.moodLabel(for: entry.mood)
        
        var config = cell.defaultContentConfiguration()
        config.text = "\(moodEmoji)  \(moodLabel)  •  Energy: \(entry.energy)/10"
        config.secondaryText = dateStr
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        config.secondaryTextProperties.color = .gray
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Journal Entries"
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        let detailVC = EntryDetailViewController()
        detailVC.entry = entry
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = entries[indexPath.row]
            DataManager.shared.deleteEntry(entry)
            entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if entries.isEmpty {
                emptyLabel.isHidden = false
                tableView.isHidden = true
            }
        }
    }
}
