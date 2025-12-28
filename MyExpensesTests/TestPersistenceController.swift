//
//  TestPersistenceController.swift
//  MyExpensesTests
//
//  Created by Narsu Patil on 28/12/25.
//

import XCTest
import CoreData
@testable import MyExpenses

final class TestPersistenceController {

    static func makeInMemoryContainer() -> NSPersistentContainer {
        let model = PersistenceController.makeModel()
        let container = NSPersistentContainer(
            name: "TestExpenseModel",
            managedObjectModel: model
        )

        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        return container
    }
}
