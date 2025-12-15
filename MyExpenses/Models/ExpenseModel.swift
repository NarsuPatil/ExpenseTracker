//
//  ExpenseModel.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import Foundation
// MARK: - Domain Model (struct) for UI use

struct ExpenseModel: Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory

    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), category: ExpenseCategory) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }

    init(from mo: ExpenseMO) {
        self.id = mo.id
        self.title = mo.title
        self.amount = mo.amount
        self.date = mo.date
        self.category = ExpenseCategory(rawValue: mo.category) ?? .others
    }
}
