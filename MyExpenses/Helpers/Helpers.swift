//
//  Helpers.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import Foundation

extension NumberFormatter {
    static var currency: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = "INR"          
            f.currencySymbol = "₹"
            f.locale = Locale(identifier: "en_IN")
            f.maximumFractionDigits = 2
            return f
        }()
    static var shortCurrency: NumberFormatter = {
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = 0; f.locale = Locale.current; return f
    }()
}

extension DateFormatter {
    static var short: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .none; return f
    }()
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps)!
    }
}
