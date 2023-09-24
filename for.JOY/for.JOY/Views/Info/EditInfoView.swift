//
//  EditInfoView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

struct EditInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var realmManager: RealmManager
    @State private var title: String = ""
    @State private var tag: String?
    @State private var date = Date()
    @State private var isShowAlert = false
    @State private var showTagView = false

    var selectedData: Memory
    let padding = UIScreen.height/844

    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()

                VStack {
                    imageView()

                    VStack {
                        titleView()

                        Divider()

                        tagView()
                        Divider()
                        DatePicker(
                            "날짜",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .tint(Color.joyBlue)
                    }
                    .padding()
                    .background(Color.joyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                }
                .background(Color.joyBlack)
                .foregroundColor(Color.black)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: backButton)
                .navigationBarItems(trailing: doneButton)
                .navigationBarColor(UIColor(.joyBlack))

                .onAppear {
                    title = selectedData.title
                    tag = selectedData.tag == "없음" ? nil : selectedData.tag
                    date = selectedData.date
                }

                .alert("편집을 취소하시겠습니까?", isPresented: $isShowAlert, actions: {
                    Button("이어서 편집", role: .cancel) { }
                    Button("편집 취소", role: .destructive) { dismiss() }
                }, message: {
                    Text("편집이 취소되면 수정 사항이 저장되지 않습니다.")
                })

                .sheet(isPresented: $showTagView) {
                    InfoTagView(selectTag: $tag, showTagView: $showTagView)
                }
            }
        }
    }

    private var backButton: some View {
        Button {
            isShowAlert = true
        } label: {
            Text("취소")
                .foregroundColor(.red)
        }
    }

    private var doneButton: some View {
        Button(
            action: {
                realmManager.updateMemory(selectedData.id, title, tag)
                let tag = DataManager().selectedTag
                if tag != nil {
                    realmManager.selectYealryMemories(tag)
                } else {
                    realmManager.selectYealryMemories()
                }
                dismiss()
            }, label: {
                Text("저장")
                    .foregroundColor(Color.joyBlue)
            }
        )
    }
}

extension EditInfoView {
    @ViewBuilder
    func imageView() -> some View {
        Image(uiImage: UIImage(data: Data(base64Encoded: selectedData.img)!) ?? UIImage(named: "test")!)
            .resizable()
            .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
            .frame(width: 350*padding, height: 466*padding)
            .cornerRadius(10)
            .clipped()
            .padding(.horizontal, 15)
            .padding(.top, -30*padding)
            .padding(.bottom, 30*padding)
    }

    @ViewBuilder
    func titleView() -> some View {
        HStack {
            Text("제목")
            Spacer(minLength: 0)
            TextField("\(selectedData.title)", text: $title)
                .accentColor(.joyBlue)
                .font(.system(size: (17.0 - CGFloat(selectedData.title.count)*0.3)))
                .multilineTextAlignment(.trailing)
                .onChange(of: title) { newValue in
                    title = String(newValue.prefix(20))
                }
                .padding(.trailing, 4)
        }
        .listRowBackground(Color.joyWhite)
    }

    @ViewBuilder
    func tagView() -> some View {
        HStack {
            Text("태그")
                .frame(width: 60, alignment: .leading)

            Spacer(minLength: 0)

            Button(
                action: {showTagView = true},
                label: {
                    Text(tag ?? "없음")
                        .frame(maxWidth: 250, alignment: .trailing)
                }
            )
        }
        .listRowBackground(Color.joyWhite)
    }
}

struct EditInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditInfoView(realmManager: RealmManager.shared, selectedData: Memory())
    }
}
