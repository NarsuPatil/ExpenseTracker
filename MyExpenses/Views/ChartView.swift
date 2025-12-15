//
//  ChartView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Charts

struct CategoryBarChartView: View {
    var categoryData: [ExpenseCategory: Double]
    var body: some View {
        let items = ExpenseCategory.allCases.map { (cat: $0, value: categoryData[$0] ?? 0) }
        Chart(items, id: \.cat) { item in
            BarMark(x: .value("Category", item.cat.displayName), y: .value("Amount", item.value))
                .foregroundStyle(by: .value("CategoryColor", item.cat.displayName))
                .annotation(position: .top) { Text(NumberFormatter.shortCurrency.string(from: NSNumber(value: item.value)) ?? "0") .font(.caption) }
        }
        .chartXAxisLabel("Category")
        .chartYAxisLabel("Amount")
    }
}

struct MonthlyLineChartView: View {
    var monthly: [(month: Date, total: Double)]
    var body: some View {
        Chart(monthly, id: \.month) { item in
            LineMark(x: .value("Month", item.month, unit: .month), y: .value("Total", item.total))
            PointMark(x: .value("Month", item.month, unit: .month), y: .value("Total", item.total))
        }
        .chartXAxis { AxisMarks(values: .stride(by: .month)) { value in AxisGridLine(); AxisValueLabel(format: .dateTime.month(.abbreviated)) } }
        .chartYAxisLabel("Amount")
    }
}
