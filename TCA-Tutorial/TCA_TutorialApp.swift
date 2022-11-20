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
            ContentView(store: Store(initialState: AppState(todos: [
                Todo(
                    id: UUID(),
                    description: "Milk",
                    isComplete: false
                ),
                Todo(
                    id: UUID(),
                    description: "Eggs",
                    isComplete: false
                ),
                Todo(
                    id: UUID(),
                    description: "Hand Soap",
                    isComplete: false
                ),
            ]), reducer: appReducer,
                                     environment: AppEnvironment(
                                        mainQueue : DispatchQueue.main.eraseToAnyScheduler(),
                                        uuid: UUID.init)))
        }
    }
}
