//
//  for_JOYApp.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

@main
struct ForJoy: App {
    @StateObject var permissionHandler = PermissionHandler()

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    permissionHandler.requestPermissions()
                }
        }
    }
}
