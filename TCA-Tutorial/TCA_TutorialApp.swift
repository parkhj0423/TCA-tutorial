//
//  TCA_TutorialApp.swift
//  TCA-Tutorial
//
//  Created by 박현우 on 2022/11/02.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_TutorialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
        }
    }
}
