//
//  Memory.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/23.
//

import Foundation
import RealmSwift

class Memory: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title = ""
    @Persisted var year = 0
    @Persisted var date = Date()
    @Persisted var tag = ""
    @Persisted var img = ""
    @Persisted var voice = ""
}
