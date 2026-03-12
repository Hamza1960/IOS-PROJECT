//
//  DailyEntryViewController.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Screen 2: Daily Entry
//  Mood selector (5 emoji buttons), energy slider (1-10), notes text area, and save.
//

import UIKit

class DailyEntryViewController: UIViewController {
    
    private var selectedMood: Int16 = 0
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "How are you feeling?"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let energySectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Energy Level"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let energySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = 5
        slider.minimumTrackTintColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let energyValueLabel: UILabel = {
        let label = UILabel()
        label.text = "5 / 10"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Notes (Optional)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor
        tv.layer.borderWidth = 2
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💾 Save Entry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var moodButtons: [UIButton] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log Today"
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
        updateDateLabel()
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(dateCard)
        dateCard.addSubview(dateTitleLabel)
        contentView.addSubview(moodSectionLabel)
        contentView.addSubview(moodStackView)
        contentView.addSubview(energySectionLabel)
        contentView.addSubview(energySlider)
        contentView.addSubview(energyValueLabel)
        contentView.addSubview(notesSectionLabel)
        contentView.addSubview(notesTextView)
        contentView.addSubview(saveButton)
        
        // Create mood buttons
        let moods: [(emoji: String, label: String, value: Int16)] = [
            ("😄", "Very Happy", 5),
            ("😊", "Happy", 4),
            ("😐", "Neutral", 3),
            ("😔", "Sad", 2),
            ("😢", "Very Sad", 1)
        ]
        
        for mood in moods {
            let button = UIButton(type: .system)
            button.tag = Int(mood.value)
            
            let container = UIView()
            container.isUserInteractionEnabled = false
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let emojiLabel = UILabel()
            emojiLabel.text = mood.emoji
            emojiLabel.font = UIFont.systemFont(ofSize: 32)
            emojiLabel.textAlignment = .center
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let textLabel = UILabel()
            textLabel.text = mood.label
            textLabel.font = UIFont.systemFont(ofSize: 9, weight: .medium)
            textLabel.textColor = .gray
            textLabel.textAlignment = .center
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            
            button.addSubview(container)
            container.addSubview(emojiLabel)
            container.addSubview(textLabel)
            
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor
            button.layer.cornerRadius = 12
            button.backgroundColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(moodSelected(_:)), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                emojiLabel.topAnchor.constraint(equalTo: container.topAnchor),
                emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                textLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
                textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
            
            moodButtons.append(button)
            moodStackView.addArrangedSubview(button)
        }
        
        energySlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            dateCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dateCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateTitleLabel.topAnchor.constraint(equalTo: dateCard.topAnchor, constant: 12),
            dateTitleLabel.centerXAnchor.constraint(equalTo: dateCard.centerXAnchor),
            dateTitleLabel.bottomAnchor.constraint(equalTo: dateCard.bottomAnchor, constant: -12),
            
            moodSectionLabel.topAnchor.constraint(equalTo: dateCard.bottomAnchor, constant: 25),
            moodSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            moodStackView.topAnchor.constraint(equalTo: moodSectionLabel.bottomAnchor, constant: 12),
            moodStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            moodStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            moodStackView.heightAnchor.constraint(equalToConstant: 80),
            
            energySectionLabel.topAnchor.constraint(equalTo: moodStackView.bottomAnchor, constant: 30),
            energySectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            energySlider.topAnchor.constraint(equalTo: energySectionLabel.bottomAnchor, constant: 15),
            energySlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            energySlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            energyValueLabel.topAnchor.constraint(equalTo: energySlider.bottomAnchor, constant: 10),
            energyValueLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            notesSectionLabel.topAnchor.constraint(equalTo: energyValueLabel.bottomAnchor, constant: 25),
            notesSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            notesTextView.topAnchor.constraint(equalTo: notesSectionLabel.bottomAnchor, constant: 12),
            notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
            
            saveButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 25),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "📅 EEEE, MMMM d, yyyy"
        dateTitleLabel.text = formatter.string(from: Date())
    }
    
    // MARK: - Actions
    
    @objc private func moodSelected(_ sender: UIButton) {
        selectedMood = Int16(sender.tag)
        
        // Reset all button styles
        for btn in moodButtons {
            btn.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor
            btn.backgroundColor = .white
            btn.transform = .identity
        }
        
        // Highlight selected
        UIView.animate(withDuration: 0.2) {
            sender.layer.borderColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0).cgColor
            sender.backgroundColor = UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.1)
            sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        energyValueLabel.text = "\(value) / 10"
    }
    
    @objc private func saveTapped() {
        guard selectedMood > 0 else {
            let alert = UIAlertController(title: "Select Mood", message: "Please select how you're feeling today.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let energy = Int16(energySlider.value)
        let notes = notesTextView.text ?? ""
        
        DataManager.shared.saveEntry(mood: selectedMood, energy: energy, notes: notes, date: Date())
        
        let alert = UIAlertController(title: "Saved! ✅", message: "Your journal entry has been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
