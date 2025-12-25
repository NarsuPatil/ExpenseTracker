//
//  ExpensesListView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Combine
// MARK: - List View with Add/Edit/Delete

struct ExpensesListView: View {
    @EnvironmentObject var vm: ExpensesViewModel
    @State private var showingAdd = false
    @State private var editing: ExpenseModel? = nil

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $vm.searchText)
                List {
                    ForEach(vm.expenses) { expense in
                        HStack {
                            CategoryIconView(category: expense.category)
                            VStack(alignment: .leading) {
                                Text(expense.title).font(.headline)
                                Text(expense.date, formatter: DateFormatter.short)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(NumberFormatter.currency.string(from: NSNumber(value: expense.amount)) ?? "0")
                                .bold()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editing = expense }
                    }
                    .onDelete(perform: { idx in
                        Task { await delete(at: idx) }
                    })
                }
            }
            .navigationTitle("Expenses")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button { showingAdd = true } label: { Image(systemName: "plus") } } }
            .sheet(isPresented: $showingAdd) { AddEditExpenseView() }
            .sheet(item: $editing) { exp in AddEditExpenseView(expense: exp) }
            .onAppear { Task { await vm.reload() } }
        }
    }

    func delete(at offsets: IndexSet) async {
        for idx in offsets {
            let e = vm.expenses[idx]
            await vm.deleteExpense(e)
        }
    }
}
