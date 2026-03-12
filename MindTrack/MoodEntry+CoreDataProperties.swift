//
//  MoodEntry+CoreDataProperties.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//

import Foundation
import CoreData

extension MoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntry> {
        return NSFetchRequest<MoodEntry>(entityName: "MoodEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var mood: Int16
    @NSManaged public var energy: Int16
    @NSManaged public var notes: String?
    @NSManaged public var date: Date?
}

extension MoodEntry: Identifiable {
}
