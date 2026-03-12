//
//  DataManager.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//

import UIKit
import CoreData

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Create
    
    func saveEntry(mood: Int16, energy: Int16, notes: String, date: Date) {
        let entry = MoodEntry(context: context)
        entry.mood = mood
        entry.energy = energy
        entry.notes = notes
        entry.date = date
        entry.id = UUID()
        
        do {
            try context.save()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
    
    // MARK: - Read
    
    func fetchAllEntries() -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func fetchEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func fetchThisWeekEntries() -> [MoodEntry] {
        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return []
        }
        return fetchEntries(from: startOfWeek, to: endOfWeek)
    }
    
    // MARK: - Delete
    
    func deleteEntry(_ entry: MoodEntry) {
        context.delete(entry)
        do {
            try context.save()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    func moodEmoji(for value: Int16) -> String {
        switch value {
        case 5: return "😄"
        case 4: return "😊"
        case 3: return "😐"
        case 2: return "😔"
        case 1: return "😢"
        default: return "😐"
        }
    }
    
    func moodLabel(for value: Int16) -> String {
        switch value {
        case 5: return "Very Happy"
        case 4: return "Happy"
        case 3: return "Neutral"
        case 2: return "Sad"
        case 1: return "Very Sad"
        default: return "Neutral"
        }
    }
    
    func moodColor(for value: Int16) -> UIColor {
        switch value {
        case 5: return UIColor(red: 0.42, green: 0.81, blue: 0.50, alpha: 1.0)
        case 4: return UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0)
        case 3: return UIColor(red: 1.00, green: 0.85, blue: 0.24, alpha: 1.0)
        case 2: return UIColor(red: 1.00, green: 0.60, blue: 0.40, alpha: 1.0)
        case 1: return UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 1.0)
        default: return .gray
        }
    }
}
