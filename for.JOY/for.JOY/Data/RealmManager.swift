//
//  RealmManager.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/23.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private var memories: Results<Memory>?
    @Published private var yearlyMemories: Results<Memory>?
    @Published var distinctYears: [Int] = []
    @Published var distinctTags: [String] = []
    init() {
        openRealm()
        selectAllMemories()
    }
    func openRealm() {
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
    }
    func selectAllMemories() {
        if let localRealm = localRealm {
            memories = localRealm.objects(Memory.self).sorted(byKeyPath: "date", ascending: false)
        }
        getDistinctYears()
        getDistinctTags()
    }
    func getDistinctYears() {
        distinctYears = Array(Set(memories?.compactMap { $0.year } ?? []))
    }
    func getDistinctTags() {
        distinctTags = Array(Set(memories?.compactMap { $0.tag } ?? []))
    }
    func selectYearlyMemories(year: Int) -> [Memory] {
        return memories?.filter { $0.year == year } ?? []
    }
    func addMemories(_ memory: Memory) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(memory)
                }
            } catch {
                print("Error adding Realm: \(error)")
            }
        }
    }
}
