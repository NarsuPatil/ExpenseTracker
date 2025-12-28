//
//  ExpenseRepositoryTests.swift
//  MyExpensesTests
//
//  Created by Narsu Patil on 29/12/25.
//

import XCTest
@testable import MyExpenses

final class ExpenseRepositoryTests: XCTestCase {

    var repo: ExpenseRepository!

    override func setUp() {
        let container = TestPersistenceController.makeInMemoryContainer()
        repo = ExpenseRepository(container: container)
    }

    func testAddExpense() throws {
        let expense = ExpenseModel(
            title: "Groceries",
            amount: 500,
            category: .groceries
        )

        try repo.add(expense)

        let all = try repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.title, "Groceries")
    }

    func testUpdateExpense() throws {
        var expense = ExpenseModel(
            title: "Taxi",
            amount: 300,
            category: .transport
        )

        try repo.add(expense)

        expense.title = "Uber"
        expense.amount = 350

        try repo.update(expense)

        let updated = try repo.fetchAll().first
        XCTAssertEqual(updated?.title, "Uber")
        XCTAssertEqual(updated?.amount, 350)
    }

    func testDeleteExpense() throws {
        let expense = ExpenseModel(
            title: "Movie",
            amount: 250,
            category: .entertainment
        )

        try repo.add(expense)
        try repo.delete(expense)

        let all = try repo.fetchAll()
        XCTAssertTrue(all.isEmpty)
    }
}

