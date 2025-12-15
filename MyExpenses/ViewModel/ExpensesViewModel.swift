//
//  ExpensesViewModel.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import SwiftUI
import Combine
// MARK: - ViewModel (Combine + MVVM)
@MainActor
final class ExpensesViewModel: ObservableObject {
    // Input / filters
    @Published var searchText: String = ""
    @Published var selectedCategory: ExpenseCategory? = nil
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil

    // Output
    @Published private(set) var expenses: [ExpenseModel] = []
    @Published private(set) var totalForCurrentMonth: Double = 0
    @Published private(set) var categoryTotalsForCurrentPeriod: [ExpenseCategory: Double] = [:]
    @Published private(set) var monthlyTotalsLast12: [(month: Date, total: Double)] = []

    private var repo: ExpenseRepository
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable?
    private let calendar = Calendar.current

    init(repo: ExpenseRepository = ExpenseRepository()) {
        self.repo = repo

        // reactively recompute when filters change
        Publishers.CombineLatest4($searchText.removeDuplicates(), $selectedCategory.removeDuplicates(by: { $0?.rawValue == $1?.rawValue }), $startDate.removeDuplicates(by: { ($0 ?? Date.distantPast) == ($1 ?? Date.distantPast) }), $endDate.removeDuplicates(by: { ($0 ?? Date.distantFuture) == ($1 ?? Date.distantFuture) }))
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                Task { await self!.reload() }
            }
            .store(in: &cancellables)

        // initial load
        Task { await reload() }

        // small timer to observe external Core Data changes (could be improved with NSManagedObjectContextDidSave)
        refreshTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in Task { await self?.reloadIfNeeded() } }
    }

    // MARK: - CRUD wrappers
    func addExpense(_ expense: ExpenseModel) async {
        do {
            try repo.add(expense)
            await reload()
        } catch {
            print("Add error: \(error)")
        }
    }

    func updateExpense(_ expense: ExpenseModel) async {
        do { try repo.update(expense); await reload() } catch { print(error) }
    }

    func deleteExpense(_ expense: ExpenseModel) async {
        do { try repo.delete(expense); await reload() } catch { print(error) }
    }

    // MARK: - Filtering helpers
    private func buildPredicate() -> NSPredicate? {
        var preds: [NSPredicate] = []
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let s = searchText.trimmingCharacters(in: .whitespaces)
            preds.append(NSPredicate(format: "title CONTAINS[cd] %@", s))
        }
        if let cat = selectedCategory {
            preds.append(NSPredicate(format: "category == %@", cat.rawValue))
        }
        if let start = startDate {
            preds.append(NSPredicate(format: "date >= %@", start as NSDate))
        }
        if let end = endDate {
            // include end of day
            let e = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
            preds.append(NSPredicate(format: "date <= %@", e as NSDate))
        }
        if preds.isEmpty { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: preds)
    }

    // MARK: - Reload & derived
    private var lastLoadedFingerprint: Int = 0

    func reloadIfNeeded() async {
        // naive fingerprint to avoid redundant reloads
        do {
            let all = try repo.fetchAll()
            let fp = all.hashValue
            if fp != lastLoadedFingerprint {
                await MainActor.run { self.expenses = all; self.recomputeDerived() }
                lastLoadedFingerprint = fp
            }
        } catch {
            print("reloadIfNeeded error: \(error)")
        }
    }

    func reload() async {
        do {
            let predicate = buildPredicate()
            let items = try repo.fetch(with: predicate)
            await MainActor.run {
                self.expenses = items
                self.recomputeDerived()
            }
        } catch {
            print("Reload error: \(error)")
        }
    }

    private func recomputeDerived() {
        computeTotalForCurrentMonth()
        computeCategoryTotalsForCurrentPeriod()
        computeMonthlyTotalsLast12()
    }

    private func computeTotalForCurrentMonth() {
        let comps = calendar.dateComponents([.year, .month], from: Date())
        guard let start = calendar.date(from: comps) else { return }
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        totalForCurrentMonth = expenses.filter { $0.date >= start && $0.date < end }.reduce(0) { $0 + $1.amount }
    }

    private func computeCategoryTotalsForCurrentPeriod() {
        var dict = [ExpenseCategory: Double]()
        for c in ExpenseCategory.allCases { dict[c] = 0 }
        for e in expenses { dict[e.category, default: 0] += e.amount }
        categoryTotalsForCurrentPeriod = dict
    }

    private func computeMonthlyTotalsLast12() {
        var arr: [(Date, Double)] = []
        let now = Date()
        for i in (0..<12).reversed() {
            if let monthStart = calendar.date(byAdding: .month, value: -i, to: calendar.startOfMonth(for: now)) {
                let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
                let total = expenses.filter { $0.date >= monthStart && $0.date < monthEnd }.reduce(0) { $0 + $1.amount }
                arr.append((monthStart, total))
            }
        }
        monthlyTotalsLast12 = arr
    }

    // MARK: - Export
    func exportCSV() -> String {
        do {
            let predicate = buildPredicate()
            return try repo.exportCSV(predicate: predicate)
        } catch {
            return "error,\(error)"
        }
    }
}
