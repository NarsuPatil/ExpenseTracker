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
        let container = TestPersistenceController.makeInMemoryContainer()
        let repo = ExpenseRepository(container: container)
        vm = await ExpensesViewModel(repo: repo)

        try repo.add(
            ExpenseModel(title: "Groceries", amount: 500, category: .groceries)
        )
        try repo.add(
            ExpenseModel(title: "Bus", amount: 100, category: .transport)
        )

        await vm.reload()
    }

    func testFetchExpenses() async {
        await MainActor.run {
            XCTAssertEqual(vm.expenses.count, 2)
        }
    }

    func testSearchFilter() async {
        await MainActor.run {
            vm.searchText = "Bus"
        }
        await vm.reload()

        await MainActor.run {
            XCTAssertEqual(vm.expenses.count, 1)
            XCTAssertEqual(vm.expenses.first?.category, .transport)
        }
    }

    func testMonthlyTotal() async {
        await vm.reload()

        await MainActor.run {
            XCTAssertEqual(vm.totalForCurrentMonth, 600)
        }
    }
    
}
