//
//  ExpenseCategory.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI

// MARK: - Category definitions (icons + color coding)

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case groceries
    case transport
    case entertainment
    case bills
    case health
    case others

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .groceries: return "Groceries"
        case .transport: return "Transport"
        case .entertainment: return "Entertainment"
        case .bills: return "Bills"
        case .health: return "Health"
        case .others: return "Others"
        }
    }

    var systemIcon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .transport: return "car.fill"
        case .entertainment: return "ticket.fill"
        case .bills: return "doc.text.fill"
        case .health: return "cross.fill"
        case .others: return "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .groceries: return Color("GroceriesColor")
        case .transport: return Color("TransportColor")
        case .entertainment: return Color("EntertainmentColor")
        case .bills: return Color("BillsColor")
        case .health: return Color("HealthColor")
        case .others: return Color("OthersColor")
        }
    }
}
