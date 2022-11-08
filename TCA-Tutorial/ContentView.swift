//
//  ContentView.swift
//  TCA-Tutorial
//
//  Created by 박현우 on 2022/11/02.
//

import SwiftUI
import ComposableArchitecture

struct Todo : Equatable, Identifiable {
    let id : UUID
    var description : String = ""
    var isComplete : Bool = false
}

struct AppState : Equatable {
    var todos : [Todo]
}

enum AppAction {
    case todoCheckBoxTapped(index : Int)
    case todoTextFieldChanged(index : Int, text : String)
}

struct AppEnvironment {
    
}

//struct Feature : ReducerProtocol {
//    typealias State = <#type#>
//
//    typealias Action = <#type#>
//
//    typealias _Body = <#type#>
//
//
//}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state , action, environment in
    switch action {
    case .todoCheckBoxTapped(index: let index):
        state.todos[index].isComplete.toggle()
        return .none
    case .todoTextFieldChanged(index: let index, text: let text):
        state.todos[index].description = text
        return .none
    }
}.debug()

struct ContentView: View {
    
    let store : Store<AppState, AppAction>
    //    @ObservableObject var viewStore
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
//                    zip(viewStore.todos.enumerated(), viewStore.todos)
                    ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                            Button {
                                viewStore.send(.todoCheckBoxTapped(index: index))
                            } label: {
                                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            TextField(
                                "Untitled Todo",
                                text : viewStore.binding(
                                    get : {
                                        $0.todos[index].description
                                    },
                                    send : {
                                        .todoTextFieldChanged(index: index, text: $0)
                                    }
                                )
                            )
                        }
                        .foregroundColor(todo.isComplete ? .gray : nil)
                    }
                }
                .navigationTitle("Todos")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(
            todos: [
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
                    isComplete: true
                ),
            ]
        ), reducer: appReducer, environment: AppEnvironment()))
    }
}
