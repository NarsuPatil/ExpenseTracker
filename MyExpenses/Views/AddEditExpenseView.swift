//
//  AddEditExpenseView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI

// MARK: - Add/Edit View

struct AddEditExpenseView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var vm: ExpensesViewModel

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var category: ExpenseCategory = .others
    @State private var date: Date = Date()
    private var editingId: UUID? = nil

    init(expense: ExpenseModel? = nil) {
        if let e = expense {
            _title = State(initialValue: e.title)
            _amount = State(initialValue: String(e.amount))
            _category = State(initialValue: e.category)
            _date = State(initialValue: e.date)
            editingId = e.id
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount).keyboardType(.decimalPad)
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            HStack { Image(systemName: cat.systemIcon); Text(cat.displayName) }.tag(cat)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle(editingId == nil ? "Add" : "Edit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentation.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { Task { await save() } }.disabled(title.isEmpty || Double(amount) == nil) }
            }
        }
    }

    func save() async {
        guard let amt = Double(amount) else { return }
        let model = ExpenseModel(id: editingId ?? UUID(), title: title, amount: amt, date: date, category: category)
        if editingId == nil { await vm.addExpense(model) } else { await vm.updateExpense(model) }
        presentation.wrappedValue.dismiss()
    }
}

