//
//  MyExpensesApp.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Combine


@main
struct MyExpensesApp: App {
    let persistence = PersistenceController.shared
    @StateObject var repo = ExpenseRepository()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(repo)
                .environmentObject(ExpensesViewModel(repo: repo))
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
