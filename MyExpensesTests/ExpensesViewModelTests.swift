//
//  ExpensesViewModelTests.swift
//  MyExpensesTests
//
//  Created by Narsu Patil on 29/12/25.
//

import XCTest
@testable import MyExpenses

final class ExpensesViewModelTests: XCTestCase {
    
    var vm: ExpensesViewModel!
    
    override func setUp() async throws {
        let mockRepo = MockExpenseRepository()
        vm = await ExpensesViewModel(repo: mockRepo)
    }
    
    func testFetchExpenses() async {
        let e = ExpenseModel(title: "Bus", amount: 100, category: .transport)
        
        await vm.addExpense(e)
        await MainActor.run {
            XCTAssertEqual(vm.expenses.count, 1)
        }
    }
    
    func testSearchFilter() async {
        let e = ExpenseModel(title: "Bus", amount: 100, category: .transport)
        
        await vm.addExpense(e)
        await MainActor.run {
            let today = Date()
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            vm.searchText = "Bus"
            vm.selectedCategory = .transport
            vm.startDate = yesterday
            vm.endDate = Date()
        }
        await vm.reload()
        
        await MainActor.run {
            XCTAssertEqual(vm.expenses.count, 1)
            XCTAssertEqual(vm.expenses.first?.category, .transport)
        }
    }
    
    func testMonthlyTotal() async {
        let e = ExpenseModel(title: "Groceries", amount: 500, category: .groceries)
        let e2 = ExpenseModel(title: "Bus", amount: 100, category: .transport)
        let e3 = ExpenseModel(title: "others", amount: 100, category: .others)
        
        
        await vm.addExpense(e)
        await vm.addExpense(e2)
        await vm.addExpense(e3)
        await vm.reload()
        
        await MainActor.run {
            XCTAssertEqual(vm.totalForCurrentMonth, 700)
        }
    }
    
    func testEditExpenseFlow() async {
        let original = ExpenseModel(title: "Entertainment", amount: 500, category: .entertainment)
        await vm.addExpense(original)
        let updateM = ExpenseModel(id: original.id,title: "Food", amount: 300, category: .bills)
        await vm.updateExpense(updateM)
        
        
        let updated = await MainActor.run { vm.expenses.first }
        XCTAssertEqual(updated?.title, "Food")
        XCTAssertEqual(updated?.amount, 300)
    }
    func testAddExpense() async {
        let e = ExpenseModel(title: "Groceries", amount: 500, category: .groceries)
        
        
        await vm.addExpense(e)
        await MainActor.run {
            XCTAssertEqual(vm.expenses.count, 1)
        }
    }
    func testDeleteExpense() async {
        let e = ExpenseModel(title: "Transport", amount: 500, category: .transport)
        await vm.addExpense(e)
        await vm.deleteExpense(e)
        let totalExpenses = await vm.expenses
        
        await MainActor.run {
            XCTAssertEqual(totalExpenses.count, 0)
        }
    }
    
}
