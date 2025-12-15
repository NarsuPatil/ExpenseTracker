//
//  ContentView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Combine

struct MainTabView: View {
    @EnvironmentObject var repo: ExpenseRepository
    @EnvironmentObject var vm: ExpensesViewModel
    
    var body: some View {
        TabView {
            ExpensesListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.pie") }
            FiltersExportView()
                .tabItem { Label("Filters/Export", systemImage: "line.3.horizontal.decrease.circle") }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty { Button(action: { text = "" }) { Image(systemName: "xmark.circle.fill") } }
        }
        .padding(.horizontal)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


