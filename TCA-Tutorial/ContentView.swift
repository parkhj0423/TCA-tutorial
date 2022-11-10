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

enum TodoAction {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {
    
}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState : Equatable {
    var todos : [Todo]
}

enum AppAction {
    case addButtonTapped
    case todo(index : Int, action : TodoAction)
    //    case todoCheckBoxTapped(index : Int)
    //    case todoTextFieldChanged(index : Int, text : String)
}

struct AppEnvironment {
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: UUID()), at: 0)
            return .none
        case .todo(index: let index, action: let action):
            return .none
        }
    }
).debug()

//AnyReducer<AppState, AppAction, AppEnvironment> { state , action, environment in
//    switch action {
//    case .todoCheckBoxTapped(index: let index):
//        state.todos[index].isComplete.toggle()
//        return .none
//    case .todoTextFieldChanged(index: let index, text: let text):
//        state.todos[index].description = text
//        return .none
//    }
//}.debug()

struct ContentView: View {
    
    let store : Store<AppState, AppAction>
    //    @ObservableObject var viewStore
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    // swift 5.2에서 사용가능한 클로져 축약 문법
                    ForEachStore(
                        self.store.scope(
                            state: \.todos,
                            action: AppAction.todo(index:action:)
                        )
                    ) { todoStore in
                        TodoView(store: todoStore)
                    }
                }
                .navigationTitle("Todos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Text("Add")
                        }
                    }
                }
                
                
                //                    ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                //                        HStack {
                //                            Button {
                //                                viewStore.send(.todo(index: index, action: .checkboxTapped))
                //                            } label: {
                //                                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                //                            }
                //                            .buttonStyle(PlainButtonStyle())
                //
                //                            TextField(
                //                                "Untitled Todo",
                //                                text : viewStore.binding(
                //                                    get : {
                //                                        $0.todos[index].description
                //                                    },
                //                                    send : {
                //                                        .todo(index: index, action: .textFieldChanged($0))
                //                                    }
                //                                )
                //                            )
                //                        }
                //                        .foregroundColor(todo.isComplete ? .gray : nil)
                //                    }
                //                }
                
            }
        }
    }
    
    //    private func todoScope() -> Store<Todo, TodoAction> {
    //        return self.store.scope {
    //            $0.todos
    //        } action: {
    //            AppAction.todo(index: $0, action: $1)
    //        }
    //
    //    }
    //
}

struct TodoView : View {
    let store : Store<Todo, TodoAction>
    
    var body: some View {
        // WithViewStore의 클로져 인자로는 viewStore가 와야함.
        WithViewStore(store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.checkboxTapped)
                } label: {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "Untitled Todo",
                    text : viewStore.binding(
                        get : \.description,
                        send : TodoAction.textFieldChanged
                    )
                    
                    // 위와 같이 축약 가능!!!!
                    //                    viewStore.binding(
                    //                        get : {
                    //                            $0.description
                    //                        },
                    //                        send : {
                    //                            .textFieldChanged($0)
                    //                        }
                    //                    )
                    
                    
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
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
