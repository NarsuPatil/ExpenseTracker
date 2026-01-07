//
//  MockExpenseRepository.swift
//  MyExpensesTests
//
//  Created by Narsu Patil on 06/01/26.
//

import Foundation
final class MockExpenseRepository: ExpenseRepositoryProtocol {
    func fetch(with predicate: NSPredicate?, limit: Int?, sort: [NSSortDescriptor]?) throws -> [ExpenseModel] {
        storage
    }
    
    func exportCSV(predicate: NSPredicate?) throws -> String {
        "csv"
    }
    

    var storage: [ExpenseModel] = []

    func fetchAll() throws -> [ExpenseModel] {
        storage
    }

    func add(_ expense: ExpenseModel) throws {
        storage.append(expense)
    }

    func update(_ expense: ExpenseModel) throws {
        if let index = storage.firstIndex(where: { $0.id == expense.id }) {
            storage[index] = expense
        }
    }

    func delete(_ expense: ExpenseModel) throws {
        storage.removeAll { $0.id == expense.id }
    }
}
