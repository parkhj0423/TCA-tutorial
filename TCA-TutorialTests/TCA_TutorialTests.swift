//
//  TCA_TutorialTests.swift
//  TCA-TutorialTests
//
//  Created by 박현우 on 2022/11/02.
//

import XCTest
import ComposableArchitecture
@testable import TCA_Tutorial

final class TCA_TutorialTests: XCTestCase {
    
    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "abcd-efgh")!,
                        description: "Milk",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(uuid: { UUID(uuidString: "abcd-efgh")! })
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            }
        )
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(todos: []),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { UUID(uuidString: "abcd-efgh")! }
            )
        )
        
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [
                    Todo(
                        id: UUID(uuidString: "abcd-efgh")!,
                        description: "",
                        isComplete: false
                    )
                ]
            }
        )
    }
    
    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { fatalError("unimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
                //        $0.todos = [
                //          $0.todos[1],
                //          $0.todos[0],
                //        ]
                $0.todos.swapAt(0, 1)
                
                //        $0.todos = [
                //          Todo(
                //            description: "Eggs",
                //            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                //            isComplete: false
                //          ),
                //
                //          Todo(
                //            description: "Milk",
                //            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                //            isComplete: true
                //          ),
                //        ]
                
            }
        )
    }
    
}
