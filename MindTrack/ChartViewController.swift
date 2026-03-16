//
//  ChartViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Screen 3: Mood Charts
//  Uses Quartz 2D for custom line/bar charts.
//  Implements multi-touch gestures: pinch-to-zoom and swipe to change time range.
//

import UIKit

class ChartViewController: UIViewController {
    
    // MARK: - Properties
    
    private var entries: [MoodEntry] = []
    private var timeRange: TimeRange = .week
    
    enum TimeRange: String {
        case week = "This Week"
        case month = "This Month"
        case allTime = "All Time"
    }
    
    // MARK: - UI Elements
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Week", "Month", "All"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let moodChartLabel: UILabel = {
        let label = UILabel()
        label.text = "Mood Over Time"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodLineChartView: MoodLineChartView = {
        let view = MoodLineChartView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let energyChartLabel: UILabel = {
        let label = UILabel()
        label.text = "Energy Levels"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let energyBarChartView: EnergyBarChartView = {
        let view = EnergyBarChartView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let gestureHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Pinch to zoom • Swipe to change range"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Charts"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(moodChartLabel)
        view.addSubview(moodLineChartView)
        view.addSubview(energyChartLabel)
        view.addSubview(energyBarChartView)
        view.addSubview(gestureHintLabel)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            moodChartLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            moodChartLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            moodLineChartView.topAnchor.constraint(equalTo: moodChartLabel.bottomAnchor, constant: 10),
            moodLineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moodLineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            moodLineChartView.heightAnchor.constraint(equalToConstant: 200),
            
            energyChartLabel.topAnchor.constraint(equalTo: moodLineChartView.bottomAnchor, constant: 25),
            energyChartLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            energyBarChartView.topAnchor.constraint(equalTo: energyChartLabel.bottomAnchor, constant: 10),
            energyBarChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            energyBarChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            energyBarChartView.heightAnchor.constraint(equalToConstant: 180),
            
            gestureHintLabel.topAnchor.constraint(equalTo: energyBarChartView.bottomAnchor, constant: 12),
            gestureHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupGestures() {
        // Multi-touch: Pinch to zoom on mood chart
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        moodLineChartView.addGestureRecognizer(pinchGesture)
        
        // Swipe gestures to navigate time ranges
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        // Long press to show details
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5 // Standard duration
        longPress.delegate = self
        moodLineChartView.addGestureRecognizer(longPress)
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .week:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? now
            entries = DataManager.shared.fetchEntries(from: start, to: end)
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            entries = DataManager.shared.fetchEntries(from: start, to: end)
        case .allTime:
            entries = DataManager.shared.fetchAllEntries().reversed()
        }
        
        moodLineChartView.dataPoints = entries.map { CGFloat($0.mood) }
        moodLineChartView.labels = entries.map { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: entry.date ?? Date())
        }
        
        energyBarChartView.dataPoints = entries.map { CGFloat($0.energy) }
        energyBarChartView.labels = entries.map { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: entry.date ?? Date())
        }
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let scale = gesture.scale
            moodLineChartView.zoomScale = min(max(scale, 0.5), 3.0)
            moodLineChartView.setNeedsDisplay()
        }
    }
    
    @objc private func handleSwipeLeft() {
        switch timeRange {
        case .week:
            timeRange = .month
            segmentedControl.selectedSegmentIndex = 1
        case .month:
            timeRange = .allTime
            segmentedControl.selectedSegmentIndex = 2
        case .allTime:
            break
        }
        loadData()
    }
    
    @objc private func handleSwipeRight() {
        switch timeRange {
        case .allTime:
            timeRange = .month
            segmentedControl.selectedSegmentIndex = 1
        case .month:
            timeRange = .week
            segmentedControl.selectedSegmentIndex = 0
        case .week:
            break
        }
        loadData()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let summary = entries.isEmpty ? "No entries to display." :
            "Entries: \(entries.count), Avg Mood: \(String(format: "%.1f", entries.map { Double($0.mood) }.reduce(0, +) / Double(entries.count)))"
        
        let alert = UIAlertController(title: "Chart Summary", message: summary, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: timeRange = .week
        case 1: timeRange = .month
        case 2: timeRange = .allTime
        default: break
        }
        loadData()
    }
}

// MARK: - Gesture Delegate
extension ChartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
