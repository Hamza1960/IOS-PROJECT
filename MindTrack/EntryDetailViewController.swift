//
//  EntryDetailViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Detail view for a journal entry, showing mood, energy, notes, and date.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    var entry: MoodEntry?
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let moodCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let moodEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 64)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let energyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Energy Level"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let energyValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let energyBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.progressTintColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        pv.trackTintColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    private let notesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Entry Detail"
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
        populateData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Mood card
        moodCard.addSubview(moodEmojiLabel)
        moodCard.addSubview(moodTextLabel)
        moodCard.addSubview(dateLabel)
        
        contentStack.addArrangedSubview(moodCard)
        
        // Energy section
        let energyCard = UIView()
        energyCard.backgroundColor = .white
        energyCard.translatesAutoresizingMaskIntoConstraints = false
        energyCard.addSubview(energyTitleLabel)
        energyCard.addSubview(energyValueLabel)
        energyCard.addSubview(energyBar)
        contentStack.addArrangedSubview(energyCard)
        
        // Notes section
        let notesCard = UIView()
        notesCard.backgroundColor = .white
        notesCard.translatesAutoresizingMaskIntoConstraints = false
        notesCard.addSubview(notesTitleLabel)
        notesCard.addSubview(notesTextLabel)
        contentStack.addArrangedSubview(notesCard)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Mood card
            moodEmojiLabel.topAnchor.constraint(equalTo: moodCard.topAnchor, constant: 20),
            moodEmojiLabel.centerXAnchor.constraint(equalTo: moodCard.centerXAnchor),
            moodTextLabel.topAnchor.constraint(equalTo: moodEmojiLabel.bottomAnchor, constant: 8),
            moodTextLabel.centerXAnchor.constraint(equalTo: moodCard.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: moodTextLabel.bottomAnchor, constant: 6),
            dateLabel.centerXAnchor.constraint(equalTo: moodCard.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: -20),
            
            // Energy
            energyTitleLabel.topAnchor.constraint(equalTo: energyCard.topAnchor),
            energyTitleLabel.leadingAnchor.constraint(equalTo: energyCard.leadingAnchor),
            energyValueLabel.topAnchor.constraint(equalTo: energyTitleLabel.bottomAnchor, constant: 10),
            energyValueLabel.centerXAnchor.constraint(equalTo: energyCard.centerXAnchor),
            energyBar.topAnchor.constraint(equalTo: energyValueLabel.bottomAnchor, constant: 10),
            energyBar.leadingAnchor.constraint(equalTo: energyCard.leadingAnchor),
            energyBar.trailingAnchor.constraint(equalTo: energyCard.trailingAnchor),
            energyBar.heightAnchor.constraint(equalToConstant: 8),
            energyBar.bottomAnchor.constraint(equalTo: energyCard.bottomAnchor),
            
            // Notes
            notesTitleLabel.topAnchor.constraint(equalTo: notesCard.topAnchor),
            notesTitleLabel.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor),
            notesTextLabel.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 10),
            notesTextLabel.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor),
            notesTextLabel.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor),
            notesTextLabel.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor),
        ])
    }
    
    private func populateData() {
        guard let entry = entry else { return }
        
        moodEmojiLabel.text = DataManager.shared.moodEmoji(for: entry.mood)
        moodTextLabel.text = DataManager.shared.moodLabel(for: entry.mood)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
        dateLabel.text = formatter.string(from: entry.date ?? Date())
        
        energyValueLabel.text = "⚡ \(entry.energy) / 10"
        energyBar.progress = Float(entry.energy) / 10.0
        
        notesTextLabel.text = (entry.notes?.isEmpty ?? true) ? "No notes for this entry." : entry.notes
    }
}
