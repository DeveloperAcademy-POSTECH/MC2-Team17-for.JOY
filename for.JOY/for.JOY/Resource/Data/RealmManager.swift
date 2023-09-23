//
//  RealmManager.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/23.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    static let shared = RealmManager()
    private(set) var localRealm: Realm?
    @Published private(set) var memories: [Memory] = []
    @Published var distinctYears: [Int] = []
    @Published var distinctTags: [String] = []
    @Published var yearlyMemories: [Int: [Memory]] = [:]
    init() {
        openRealm()
        selectAllMemories()
    }
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print(RealmError.realmInitializationFailed.errorMessage)
        }
    }
    func selectAllMemories(_ tag: String? = nil) {
        if let localRealm = localRealm {
            var allMemories: [Memory] = []
            if tag == nil {
                allMemories = Array(localRealm.objects(Memory.self).sorted(byKeyPath: "date", ascending: false))
            } else {
                allMemories = Array(localRealm.objects(Memory.self).filter(NSPredicate(format: "tag == %@", tag!)).sorted(byKeyPath: "date", ascending: false))
            }
            memories = []
            allMemories.forEach { memory in
                memories.append(memory)
                yearlyMemories[memory.year, default: []].append(memory)
            }
        }
        getDistinctYears()
        getDistinctTags()
    }
    func getDistinctYears() {
        distinctYears = Array(Set(memories.compactMap { $0.year }))
    }
    func getDistinctTags() {
        distinctTags = Array(Set(memories.compactMap { $0.tag }))
    }
//    func selectYealryMemories(_ tag: String?) {
//        if let localRealm = localRealm {
//            var yearlyfilteredMemories: [Memory] = []
//            if tag != nil {
//                yearlyfilteredMemories = memories.filter { $0.tag == tag}
//            } else {
//                yearlyfilteredMemories = memories
//            }
//
//            yearlyfilteredMemories.forEach { memory in
//                yearlyMemories[memory.year, default: []].append(memory)
//            }
//        }
//    }
    func insertMemory(_ memory: Memory) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(memory)
                    selectAllMemories()
                    print(RealmSuccess.realmInserDataSucceeded.successMessage)
                }
            } catch {
                print(RealmError.realmInserDataFailed.errorMessage)
            }
        }
    }
    func updateMemory(_ id: ObjectId, _ title: String, _ tag: String, _ date: Date) {
        if let localRealm = localRealm {
            do {
                let memoryToUpdate = localRealm.objects(Memory.self).filter(NSPredicate(format: "id == %@", id))
                guard !memoryToUpdate.isEmpty else { return }
                try localRealm.write {
                    memoryToUpdate[0].title = title
                    memoryToUpdate[0].tag = tag
                    memoryToUpdate[0].date = date
                    selectAllMemories()
                    print(RealmSuccess.realmUpdateDataSucceeded.successMessage)
                }
            } catch {
                print(RealmError.realmUpdateDataFailed.errorMessage)
            }
        }
    }
    func deleteMemory(_ id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let memoryToDelete = localRealm.objects(Memory.self).filter(NSPredicate(format: "id == %@", id))
                guard !memoryToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(memoryToDelete)
                    selectAllMemories()
                    print(RealmSuccess.realmDeleteDataSucceeded.successMessage)
                }
            } catch {
                print(RealmError.realmDeleteDataFailed.errorMessage)
            }
        }
    }
}

enum RealmError: Error {
    case realmInitializationFailed
    case realmInserDataFailed
    case realmUpdateDataFailed
    case realmDeleteDataFailed
    var errorMessage: String {
        switch self {
        case .realmInitializationFailed:
            return "[Realm/Error] Failed to initialize realm."
        case .realmInserDataFailed:
            return "[Realm/Error] Failed to insert data."
        case .realmUpdateDataFailed:
            return "[Realm/Error] Failed to update data."
        case .realmDeleteDataFailed:
            return "[Realm/Error] Failed to delete data."
        }
    }
}

enum RealmSuccess {
    case realmInserDataSucceeded
    case realmUpdateDataSucceeded
    case realmDeleteDataSucceeded
    var successMessage: String {
        switch self {
        case .realmInserDataSucceeded:
            return "[Realm/Success] Succeeded in inserting data."
        case .realmUpdateDataSucceeded:
            return "[Realm/Success] Succeeded in updating data."
        case .realmDeleteDataSucceeded:
            return "[Realm/Success] Succeeded in deleting data."
        }
    }
}
