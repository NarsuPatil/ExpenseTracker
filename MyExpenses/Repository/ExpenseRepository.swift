//
//  ExpenseRepository.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import CoreData

// MARK: - Repository (CoreData operations) + Combine publisher

protocol ExpenseRepositoryProtocol {
    func fetchAll() throws -> [ExpenseModel]
    func add(_ expense: ExpenseModel) throws
    func update(_ expense: ExpenseModel) throws
    func delete(_ expense: ExpenseModel) throws
    func fetch(with predicate: NSPredicate?, limit: Int?, sort: [NSSortDescriptor]?) throws -> [ExpenseModel]
    func exportCSV(predicate: NSPredicate?) throws -> String
}

final class ExpenseRepository: ObservableObject,ExpenseRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.context = container.viewContext
        self.backgroundContext = container.newBackgroundContext()
    }
    
    func fetchAll() throws -> [ExpenseModel] {
        let req = NSFetchRequest<ExpenseMO>(entityName: "ExpenseMO")
        req.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseMO.date, ascending: false)]
        let mos = try context.fetch(req)
        return mos.map { ExpenseModel(from: $0) }
    }
    
    func fetch(with predicate: NSPredicate?, limit: Int?, sort: [NSSortDescriptor]?) throws -> [ExpenseModel] {
        
        let req = NSFetchRequest<ExpenseMO>(entityName: "ExpenseMO")
        let sortDescriptor = sort ?? [NSSortDescriptor(key: "date", ascending: false)]
        req.predicate = predicate
        req.sortDescriptors = sortDescriptor
        if let limit = limit { req.fetchLimit = limit }
        let mos = try context.fetch(req)
        return mos.map { ExpenseModel(from: $0) }
    }
    
    func add(_ expense: ExpenseModel) throws {
        try backgroundContext.performAndWait {
            let mo = NSEntityDescription.insertNewObject(forEntityName: "ExpenseMO", into: backgroundContext) as! ExpenseMO
            mo.id = expense.id
            mo.title = expense.title
            mo.amount = expense.amount
            mo.date = expense.date
            mo.category = expense.category.rawValue
            try backgroundContext.save()
        }
    }
    
    func update(_ expense: ExpenseModel) throws {
        try backgroundContext.performAndWait {
            let req = NSFetchRequest<ExpenseMO>(entityName: "ExpenseMO")
            req.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
            req.fetchLimit = 1
            let found = try backgroundContext.fetch(req)
            if let mo = found.first {
                mo.title = expense.title
                mo.amount = expense.amount
                mo.date = expense.date
                mo.category = expense.category.rawValue
                try backgroundContext.save()
            }
        }
    }
    
    func delete(_ expense: ExpenseModel) throws {
        try backgroundContext.performAndWait {
            let req = NSFetchRequest<ExpenseMO>(entityName: "ExpenseMO")
            req.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
            req.fetchLimit = 1
            let found = try backgroundContext.fetch(req)
            if let mo = found.first {
                backgroundContext.delete(mo)
                try backgroundContext.save()
            }
        }
    }
    
    // Export helper: fetch and convert to CSV string
    func exportCSV(predicate: NSPredicate? = nil) throws -> String {
        let items = try fetch(with: predicate, limit: nil, sort: [NSSortDescriptor(key: "date", ascending: false)])
        var rows = ["id,title,amount,category,date"]
        let df = ISO8601DateFormatter()
        for it in items {
            let csvLine = "\(it.id.uuidString),\("\(it.title)".replacingOccurrences(of: ",", with: " ")),\(it.amount),\(it.category.rawValue),\(df.string(from: it.date))"
            rows.append(csvLine)
        }
        return rows.joined(separator: "\n")
    }
}
