//
//  DashboardView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var vm: ExpensesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("This Month").font(.title2).bold()
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total")
                            .font(.caption).foregroundColor(.secondary)
                        Text(NumberFormatter.currency.string(from: NSNumber(value: vm.totalForCurrentMonth)) ?? "0")
                            .font(.title).bold()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))

                Text("Spending by Category").font(.headline)
                CategoryBarChartView(categoryData: vm.categoryTotalsForCurrentPeriod)
                    .frame(height: 220)

                Text("Last 12 months").font(.headline)
                MonthlyLineChartView(monthly: vm.monthlyTotalsLast12)
                    .frame(height: 220)
            }
            .padding()
        }
        .onAppear { Task { await vm.reload() } }
    }
}

