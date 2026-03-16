//
//  HomeViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Screen 1: Home Dashboard
//  Shows today's date, weekly mood summary, mini chart preview, and "Log Today" button.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0).cgColor,
            UIColor(red: 0.46, green: 0.30, blue: 0.64, alpha: 1.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "MindTrack"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekSummaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weekTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "This Week's Mood"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodEmojiLabel: UILabel = {
        let label = UILabel()
        label.text = "😊"
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodDescLabel: UILabel = {
        let label = UILabel()
        label.text = "No entries yet"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chartPreviewView: MiniChartView = {
        let view = MiniChartView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📝 Log Today's Mood", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 1.0
        return button
    }()
    
    private let logButtonGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0).cgColor,
            UIColor(red: 0.46, green: 0.30, blue: 0.64, alpha: 1.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 25
        return layer
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        updateDateLabel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshWeeklySummary()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = headerView.bounds
        logButtonGradient.frame = logButton.bounds
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Header
        view.addSubview(headerView)
        headerView.layer.insertSublayer(gradientLayer, at: 0)
        headerView.addSubview(appTitleLabel)
        headerView.addSubview(dateLabel)
        
        // Content
        view.addSubview(weekSummaryCard)
        weekSummaryCard.addSubview(weekTitleLabel)
        weekSummaryCard.addSubview(moodEmojiLabel)
        weekSummaryCard.addSubview(moodDescLabel)
        
        view.addSubview(chartPreviewView)
        
        view.addSubview(logButton)
        logButton.layer.insertSublayer(logButtonGradient, at: 0)
        logButton.addTarget(self, action: #selector(logTodayTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),
            
            appTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            appTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            
            dateLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            
            // Week Summary Card
            weekSummaryCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            weekSummaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekSummaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekTitleLabel.topAnchor.constraint(equalTo: weekSummaryCard.topAnchor, constant: 15),
            weekTitleLabel.centerXAnchor.constraint(equalTo: weekSummaryCard.centerXAnchor),
            
            moodEmojiLabel.topAnchor.constraint(equalTo: weekTitleLabel.bottomAnchor, constant: 8),
            moodEmojiLabel.centerXAnchor.constraint(equalTo: weekSummaryCard.centerXAnchor),
            
            moodDescLabel.topAnchor.constraint(equalTo: moodEmojiLabel.bottomAnchor, constant: 4),
            moodDescLabel.centerXAnchor.constraint(equalTo: weekSummaryCard.centerXAnchor),
            moodDescLabel.bottomAnchor.constraint(equalTo: weekSummaryCard.bottomAnchor, constant: -15),
            
            // Chart Preview
            chartPreviewView.topAnchor.constraint(equalTo: weekSummaryCard.bottomAnchor, constant: 20),
            chartPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chartPreviewView.heightAnchor.constraint(equalToConstant: 130),
            
            // Log Button
            logButton.topAnchor.constraint(equalTo: chartPreviewView.bottomAnchor, constant: 25),
            logButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func refreshWeeklySummary() {
        let entries = DataManager.shared.fetchThisWeekEntries()
        
        if entries.isEmpty {
            moodEmojiLabel.text = "🌟"
            moodDescLabel.text = "No entries yet"
            chartPreviewView.dataPoints = []
        } else {
            let sum = entries.reduce(0.0) { $0 + Double($1.mood) }
            let avg = sum / Double(entries.count)
            let moodValue = Int16(round(avg))
            
            moodEmojiLabel.text = DataManager.shared.moodEmoji(for: moodValue)
            moodDescLabel.text = DataManager.shared.moodLabel(for: moodValue)
            
            chartPreviewView.dataPoints = entries.map { CGFloat($0.mood) }
        }
    }
    
    // MARK: - Actions
    
    @objc private func logTodayTapped() {
        let entryVC = DailyEntryViewController()
        entryVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(entryVC, animated: true)
    }
}

// MARK: - Mini Chart View (Quartz 2D)

class MiniChartView: UIView {
    
    var dataPoints: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let inset: CGFloat = 15
        let drawRect = rect.insetBy(dx: inset, dy: inset)
        
        if dataPoints.isEmpty {
            // Draw placeholder text
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let text = "Chart Preview - Log entries to see trends"
            let size = text.size(withAttributes: attrs)
            let point = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
            text.draw(at: point, withAttributes: attrs)
            return
        }
        
        let maxVal: CGFloat = 5.0
        let stepX = drawRect.width / CGFloat(max(dataPoints.count - 1, 1))
        
        // Use a dynamic color for the line in MiniChartView to ensure it pops
        let lineColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        
        // Draw line
        context.setLineWidth(2.5)
        context.setStrokeColor(lineColor.cgColor)
        
        for (i, point) in dataPoints.enumerated() {
            let x = drawRect.minX + CGFloat(i) * stepX
            let y = drawRect.maxY - (point / maxVal) * drawRect.height
            
            if i == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
        
        // Draw dots with a dot color that works in both modes
        let dotColor = UIColor(red: 0.46, green: 0.30, blue: 0.64, alpha: 1.0)
        for (i, point) in dataPoints.enumerated() {
            let x = drawRect.minX + CGFloat(i) * stepX
            let y = drawRect.maxY - (point / maxVal) * drawRect.height
            
            context.setFillColor(dotColor.cgColor)
            context.fillEllipse(in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
        }
    }
}
