//
//  PersistenceController.swift
//  MyExpenses
//
//  Created by Narsu Patil on 14/12/25.
//

import CoreData
// MARK: - Core Data Stack (programmatic model)

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "ExpenseModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let expense = NSEntityDescription()
        expense.name = "ExpenseMO"
        expense.managedObjectClassName = "ExpenseMO"

        var properties: [NSAttributeDescription] = []

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false
        properties.append(id)

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false
        properties.append(title)

        let amount = NSAttributeDescription()
        amount.name = "amount"
        amount.attributeType = .doubleAttributeType
        amount.isOptional = false
        properties.append(amount)

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false
        properties.append(date)

        let category = NSAttributeDescription()
        category.name = "category"
        category.attributeType = .stringAttributeType
        category.isOptional = false
        properties.append(category)

        expense.properties = properties
        model.entities = [expense]
        return model
    }
}

// Provide an NSManagedObject subclass to satisfy runtime
@objc(ExpenseMO)
public class ExpenseMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var date: Date
    @NSManaged public var category: String
}

