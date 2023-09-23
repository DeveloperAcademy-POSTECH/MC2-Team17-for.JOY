//
//  InfoTagView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

struct InfoTagView: View {
    @State private var addTag: Bool = false
    @State private var newTag: String = ""
    @State private var tags = [Tag]()
    @State private var isValueSet: Bool = false

    @Binding var selectTag: String?
    @Binding var showTagView: Bool

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selectTag) {
                    ForEach(0...min(tags.count, 9), id: \.self) { index in
                        if tags.count < 10 && index == tags.count {
                            addTagView()
                        } else {
                            tagButton(index)
                        }
                    }
                    .onDelete { index in
                        tags.remove(atOffsets: index)
                        saveTags()
                    }
                }
                .cornerRadius(10)
                .background(Color.joyBlack)
                .padding(.horizontal, 20)
                .padding(.vertical, 37)
                .listStyle(.plain)
                .listRowBackground(Color.joyBlack.ignoresSafeArea())

                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                showTagView.toggle()
                            },
                            label: {
                                Image(systemName: "x.circle.fill")
                                    .foregroundColor(Color.joyGrey200)
                            }
                        )
                    }
                }
            }
            .padding(8)
            .background(Color.joyBlack)
            .foregroundColor(.black)
            .onDisappear {
                saveTags()
            }
            .onAppear {
                initTags()
            }
        }
    }

    func saveTags() {
        if let data = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(data, forKey: "tags")
        }
    }

    func initTags() {
        tags = {
            if let data = UserDefaults.standard.data(forKey: "tags"),
               let tags = try? JSONDecoder().decode([Tag].self, from: data) {
                return tags
            }
            return []
        }()

        isValueSet = UserDefaults.standard.bool(forKey: "IsValueSet")
        if isValueSet == false {
            UserDefaults.standard.set(true, forKey: "IsValueSet")
            tags.append(Tag(tagName: "우리 공주님"))
            tags.append(Tag(tagName: "우리 왕자님"))
            tags.append(Tag(tagName: "우리집"))
        }

        if tags.isEmpty {
            addTag = true
        }

        if let selectTag = selectTag, !tags.contains(where: { $0.tagName == selectTag }) {
            tags.append(Tag(tagName: selectTag))
        }
    }
}

extension InfoTagView {
    @ViewBuilder
    func addTagView() -> some View {
        HStack {
            TextField("새로운 태그", text: $newTag)
                .onChange(of: newTag) { newValue in
                    newTag = String(newValue.prefix(20))
                }
                .onSubmit {
                    if !tags.contains(where: {$0.tagName == newTag}) {
                        tags.append(Tag(tagName: newTag))
                    }
                    newTag = ""
                }

            Spacer(minLength: 0)

            Button(
                action: {newTag = ""},
                label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(Color.joyGrey200)
                }
            )
        }
        .listRowBackground(Color.joyWhite)
    }

    @ViewBuilder
    func tagButton(_ index: Int) -> some View {
        Button(
            action: {
                selectTag = (selectTag == tags[index].tagName) ? nil : tags[index].tagName
            }, label: {
                HStack {
                    Text(tags[index].tagName)
                        .tag(tags[index].tagName)
                        .foregroundColor(Color.black)

                    Spacer(minLength: 0)

                    if tags[index].tagName == selectTag {
                        Image(systemName: "checkmark")
                            .multilineTextAlignment(.trailing)
                            .font(Font.body1Kor)
                            .foregroundColor(Color.joyBlue)
                    }
                }
            }
        )
        .listRowBackground(Color.joyWhite)
    }
}

struct InfoTagView_Previews: PreviewProvider {
    static var previews: some View {
        InfoTagView(selectTag: .constant(nil), showTagView: .constant(true))
    }
}
