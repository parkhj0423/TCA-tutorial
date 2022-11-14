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

enum TodoAction : Equatable {
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

enum AppAction : Equatable {
    case addButtonTapped
    case todo(index : Int, action : TodoAction)
    case todoDelayCompleted
    //    case todoCheckBoxTapped(index : Int)
    //    case todoTextFieldChanged(index : Int, text : String)
}

struct AppEnvironment {
    var uuid : () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
            //        case .todo(index:action:):
            //        case .todo(index: _, action: _):
        case .todo(index : _, action : .checkboxTapped) :
            // 외부에서 Publisher를 실수로 Cancel해버리는 경우가 발생하지 않도록, 문자열 값으로 Cancel Id를 주는 것 보다 case 문 안에 Struct를 선언하여, case문 안의 코드 블럭에서만 접근 할 수 있는 Struct 타입의 CancelID를 만들어서 사용
            // 이렇게 되면 외부에서 실수로 해당 블록의 Publisher를 Cancel해버리는 경우가 발생하지 않음
            struct CancelDelayId : Hashable {}
            
            
//            // 1. todo Action의 checkboxTapped Action이 들어왔을 경우
//            return .concatenate(
//                // 2. concatenate Operator로 "completion effect"의 값을 가진 Publisher가 존재할 경우 Cancel 시키고,
//                Effect.cancel(id: "completion effect"),
//                // 3. 새로운 Publisher를 동작 시킨다.
//                Effect(value: AppAction.todoDelayCompleted)
//                    .delay(for: 1, scheduler: DispatchQueue.main)
//                    .eraseToEffect()
//                // cancellable은 같은 Action이 여러번 반복 되었을때 발생하는 문제를 방지하기 위함
//                    .cancellable(id: "completion effect")
//            )
            
            /// .concatenate Operator를 사용하지 않고, cancellable의 cancelInFlight 값을 true로 줘 같은 기능을 하게 할 수 있음
            
            return Effect(value: AppAction.todoDelayCompleted)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
            // cancellable은 같은 Action이 여러번 반복 되었을때 발생하는 문제를 방지하기 위함
                .cancellable(id: CancelDelayId(), cancelInFlight : true)
            
            
        case .todo(index: let index, action: let action):
            return .none
            
        case .todoDelayCompleted :
            state.todos = state.todos
                .enumerated()
                .sorted { lhs, rhs in
                    (
                        !lhs.element.isComplete && rhs.element.isComplete
                    ) || lhs.offset < rhs.offset
                }
                .map(\.element)
            
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
                    // 클로져 인자가 1개일때 KeyPath로 접근 가능
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
        ContentView(store:
                        Store(initialState: AppState(
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
                        ),
                              reducer: appReducer,
                              environment: AppEnvironment(
                                uuid: UUID.init
                              )))
    }
}
