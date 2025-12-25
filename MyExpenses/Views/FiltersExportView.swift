//
//  FiltersExportView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI

struct FiltersExportView: View {
    @EnvironmentObject var vm: ExpensesViewModel
    @State private var showingShare = false
    @State private var csvData: URL? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search & Category")) {
                    SearchBar(text: $vm.searchText)
                    Picker("Category", selection: Binding(get: { vm.selectedCategory }, set: { vm.selectedCategory = $0 })) {
                        Text("All").tag(ExpenseCategory?.none)
                        ForEach(ExpenseCategory.allCases) { c in Text(c.displayName).tag(ExpenseCategory?.some(c)) }
                    }
                }
                Section(header: Text("Date Range")) {
                    DatePicker("Start", selection: Binding(get: { vm.startDate ?? Date() }, set: { vm.startDate = $0 }), displayedComponents: .date)
                    Toggle("Use Start Date", isOn: Binding(get: { vm.startDate != nil }, set: { new in vm.startDate = new ? (vm.startDate ?? Date()) : nil }))
                    DatePicker("End", selection: Binding(get: { vm.endDate ?? Date() }, set: { vm.endDate = $0 }), displayedComponents: .date)
                    Toggle("Use End Date", isOn: Binding(get: { vm.endDate != nil }, set: { new in vm.endDate = new ? (vm.endDate ?? Date()) : nil }))
                }
                Section {
                    Button("Apply Filters") { Task { await vm.reload() } }
                    Button("Export CSV") { export() }
                }
            }
            .navigationTitle("Filters & Export")
            .sheet(isPresented: $showingShare, onDismiss: { if let u = csvData { try? FileManager.default.removeItem(at: u) } }) {
                if let url = csvData { ActivityViewController(activityItems: [url]) }
            }
            .onAppear { Task { await vm.reload() } }
        }
    }
    
    func export() {
        let csv = vm.exportCSV()
        // write to temp file and show share sheet
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("expenses_export_\(Int(Date().timeIntervalSince1970)).csv")
        do {
            try csv.data(using: .utf8)?.write(to: tmp)
            csvData = tmp
            showingShare = true
        } catch {
            print("Export error: \(error)")
        }
    }
}
