//
//  test.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/23.
//

import SwiftUI

struct Test: View {
    @StateObject var realmManager = RealmManager.shared
    var body: some View {
        VStack {
            Text("\(realmManager.distinctYears[0])")
            Text("\(realmManager.distinctTags[0])")
            List {
                ForEach(realmManager.memories, id: \.id) { memory in
                    if !memory.isInvalidated {
                        VStack {
                            Text("\(memory.id)")
                            Text("\(memory.title)")
                            Text("\(memory.year)")
                            Text("\(memory.tag)")
                            Text("\(memory.img)")
                            Text("\(memory.voice)")
                        }
                    }
                }
            }
            Spacer()
            Button {
                realmManager.insertMemory(Memory(value: ["title": "test", "year": 2023, "date": Date(), "tag": "없음", "img": "EmptyMemory", "voice": "none"] as [String : Any]))
            } label: {
                Text("Add Memory")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    )
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
