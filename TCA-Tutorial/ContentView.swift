//
//  ContentView.swift
//  TCA-Tutorial
//
//  Created by 박현우 on 2022/11/02.
//

import SwiftUI
import ComposableArchitecture

struct Todo {
    var description : String = ""
    var isComplete : Bool = false
}

struct AppState {
    var todos : [Todo]
}

enum AppAction {
    
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
    default:
        break
    }
}

struct ContentView: View {
    
    let store : Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            List {
                ForEach(self.store.state.todos) { todo in
                    
                }
            }
            .navigationTitle("Todos")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
    }
}
