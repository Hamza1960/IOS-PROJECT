//
//  SettingsViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Screen 5: Settings
//  Static UITableView with toggle switches for reminders, theme, and data management.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        return tv
    }()
    
    // Settings data
    private let sections = ["Notifications", "Appearance", "Data"]
    private let items: [[String]] = [
        ["Daily Reminder", "Reminder Time"],
        ["Dark Mode"],
        ["Export Data", "Clear All Data"]
    ]
    
    private var reminderEnabled = false
    private var darkModeEnabled = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        
        // Load saved preferences
        reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = items[indexPath.section][indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = item
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0): // Daily Reminder toggle
            cell.contentConfiguration = config
            let toggle = UISwitch()
            toggle.isOn = reminderEnabled
            toggle.onTintColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
            toggle.tag = 0
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            
        case (0, 1): // Reminder Time
            let savedTime = UserDefaults.standard.string(forKey: "reminderTime") ?? "8:00 PM"
            config.secondaryText = savedTime
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            
        case (1, 0): // Dark Mode toggle
            cell.contentConfiguration = config
            let toggle = UISwitch()
            toggle.isOn = darkModeEnabled
            toggle.onTintColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
            toggle.tag = 1
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            
        case (2, 0): // Export Data
            config.textProperties.color = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            
        case (2, 1): // Clear All Data
            config.textProperties.color = .systemRed
            cell.contentConfiguration = config
            cell.accessoryView = nil
            
        default:
            cell.contentConfiguration = config
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 1): // Reminder Time
            showTimePicker()
            
        case (2, 0): // Export Data
            exportData()
            
        case (2, 1): // Clear All Data
            confirmClearData()
            
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            reminderEnabled = sender.isOn
            UserDefaults.standard.set(reminderEnabled, forKey: "reminderEnabled")
            if reminderEnabled {
                requestNotificationPermission()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        case 1:
            darkModeEnabled = sender.isOn
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
            
            // Apply theme
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
                }
            }
        default:
            break
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                self.scheduleNotification()
            }
        }
    }
    
    private func scheduleNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard UserDefaults.standard.bool(forKey: "reminderEnabled") else { return }
        
        let timeStr = UserDefaults.standard.string(forKey: "reminderTime") ?? "8:00 PM"
        
        // Parse time string (e.g., "8:00 PM")
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let date = formatter.date(from: timeStr) else { return }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let content = UNMutableNotificationContent()
        content.title = "Time for MindTrack 🧠"
        content.body = "How are you feeling today? Take a moment to log your mood and thoughts."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func showTimePicker() {
        let alert = UIAlertController(title: "Reminder Time", message: "Choose when to receive your daily reminder.", preferredStyle: .actionSheet)
        let times = ["7:00 AM", "8:00 PM", "9:00 PM", "10:00 PM"]
        for time in times {
            alert.addAction(UIAlertAction(title: time, style: .default) { _ in
                UserDefaults.standard.set(time, forKey: "reminderTime")
                self.scheduleNotification()
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func exportData() {
        let entries = DataManager.shared.fetchAllEntries()
        var csv = "Date,Mood,Energy,Notes\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for entry in entries {
            let date = formatter.string(from: entry.date ?? Date())
            let mood = DataManager.shared.moodLabel(for: entry.mood)
            let energy = entry.energy
            let notes = (entry.notes ?? "").replacingOccurrences(of: ",", with: ";")
            csv += "\(date),\(mood),\(energy),\(notes)\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func confirmClearData() {
        let alert = UIAlertController(title: "Clear All Data", message: "Are you sure you want to delete all journal entries? This cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { _ in
            let entries = DataManager.shared.fetchAllEntries()
            for entry in entries {
                DataManager.shared.deleteEntry(entry)
            }
            
            let confirmAlert = UIAlertController(title: "Done ✅", message: "All entries have been cleared.", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(confirmAlert, animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Footer
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "MindTrack v1.0 • CSC-371 DePaul University"
        }
        return nil
    }
}
