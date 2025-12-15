//
//  CategoryIconView.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Combine

struct CategoryIconView: View {
    var category: ExpenseCategory
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color)
                .frame(width: 44, height: 44)
            Image(systemName: category.systemIcon)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}
