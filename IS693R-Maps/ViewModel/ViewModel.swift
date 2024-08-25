//
//  ViewModel.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/24/24.
//

import Foundation
import SwiftData

@Observable
class ViewModel {

    // MARK: - Properties

    // We need a ModelContext to interact with SwiftData.  All operations
    // on persistent data go through the ModelContext.
    private var modelContext: ModelContext

    // MARK: - Initialization

    // The initializer for this class remembers the ModelContext and performs
    // any initial queries needed by the app.
    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    // MARK: - Model access

    // Publish any data the app needs as stored properties.  It is our
    // responsibility as the ViewModel to know when to re-query the
    // ModelContext for updates.  These stored properties should be
    // considered "transient" in the sense that they will always be
    // re-fetched when needed.
    private(set) var filteredItems: [Item] = []
    private(set) var items: [Item] = []
    private(set) var destinations: [Destination] = []

    // MARK: - User intents

    // As usual with MVVM, create User Intent functions for anything your
    // app wants to accomplish.

//    func addIndependentItem(_ item: IndependentItem) {
//        modelContext.insert(item)
//
//        // Because the ModelContext changed, we need to re-fetch
//        fetchData()
//    }

    func addItem(_ item: Item) {
        modelContext.insert(item)

        // Because the ModelContext changed, we need to re-fetch
        fetchData()
    }
    
    func addDestination(_ destination: Destination) {
        modelContext.insert(destination)

        // Because the ModelContext changed, we need to re-fetch
        fetchData()
    }

//    func deleteIndependentItem(_ item: IndependentItem) {
//        modelContext.delete(item)
//
//        // Because the ModelContext changed, we need to re-fetch
//        fetchData()
//    }

    func deleteItem(_ item: Item) {
        modelContext.delete(item)

        // Because the ModelContext changed, we need to re-fetch
        fetchData()
    }
    
    func deleteDestination(_ destination: Destination) {
        modelContext.delete(destination)

        // Because the ModelContext changed, we need to re-fetch
        fetchData()
    }

    func replaceAllItems(
//        _ items: [Item],
//        _ independentItems: [IndependentItem],
        _ destinations: [Destination]
//        _ associations: [(String, String)]
    ) throws {
        do {
//            try modelContext.delete(model: Item.self)
            try modelContext.delete(model: Destination.self)
//            try modelContext.delete(model: IndependentItem.self)
        } catch {
            throw error
        }

//        var itemTable: [String : Item] = [:]
//        var independentItemTable: [String : IndependentItem] = [:]
        var destinationTable: [String: Destination] = [:]
        
        destinations.forEach { dest in
            destinationTable[dest.name] = dest
            modelContext.insert(dest)
        }

//        items.forEach { item in
//            itemTable[item.title] = item
//            modelContext.insert(item)
//        }

//        independentItems.forEach { item in
//            independentItemTable[item.title] = item
//            modelContext.insert(item)
//        }

//        associations.forEach { (tool, color) in
//            if let toolItem = itemTable[tool], let colorItem = independentItemTable[color] {
//                // We just need to append the IndependentItem onto the array of the
//                // corresponding Item's independentItems (or vice versa).  This
//                // creates the many-to-many association in the database.
//
//                toolItem.independentItems.append(colorItem)
//            }
//        }

        fetchData()
    }

//    func saveItem(_ item: Item?, title: String, dependentTitles: [String]) {
//        if let item {
//            editItem(item, title: title, dependentTitles: dependentTitles)
//        } else {
//            createItem(title: title, dependentTitles: dependentTitles)
//        }
//
//        fetchData()
//    }
    
    func saveDestination(
        _ destination: Destination?,
        name: String,
        dateVisited: Date,
        address: String,
        city: String,
        country: String
    ) {
        if let destination {
//            editDestination
            
        } else {
//            createDestination
        }
    }

    // MARK: - Private helpers

//    private func createItem(title: String, dependentTitles: [String]) {
//        let item = Item(title: title, dependentItems: [], independentItems: [])
//
//        dependentTitles.forEach {
//            let dependentItem = DependentItem(title: $0)
//
//            item.dependentItems.append(dependentItem)
//        }
//
//        modelContext.insert(item)
//    }
    
    private func createDestination(
        name: String,
        dateVisited: Date,
        address: String,
        city: String,
        country: String
    ) {
        let destination = Destination(dateVisited: dateVisited, name: name, address: address, city: city, country: country)

//        dependentTitles.forEach {
//            let dependentItem = DependentItem(title: $0)
//
//            item.dependentItems.append(dependentItem)
//        }

        modelContext.insert(destination)
    }

//    private func editItem(_ item: Item, title: String, dependentTitles: [String]) {
//        item.title = title
//
//        // The strategy here is to replace all the dependent items with new
//        // ones, even if some or all are the same.  The alternative is to do an
//        // array diff betwen the current and the new dependent items, deleting
//        // any that are now missing and adding any that are new.  That's kind
//        // of complex, so I'm opting for the more straightforward approach of
//        // replacing everything.
//
//        item.dependentItems.forEach {
//            modelContext.delete($0)
//        }
//
//        dependentTitles.forEach {
//            let dependentItem = DependentItem(title: $0)
//
//            item.dependentItems.append(dependentItem)
//        }
//    }
    
//    private func editDestination(_ item: Item, title: String, dependentTitles: [String]) {
//        item.title = title
//
//        // The strategy here is to replace all the dependent items with new
//        // ones, even if some or all are the same.  The alternative is to do an
//        // array diff betwen the current and the new dependent items, deleting
//        // any that are now missing and adding any that are new.  That's kind
//        // of complex, so I'm opting for the more straightforward approach of
//        // replacing everything.
//
//        item.dependentItems.forEach {
//            modelContext.delete($0)
//        }
//
//        dependentTitles.forEach {
//            let dependentItem = DependentItem(title: $0)
//
//            item.dependentItems.append(dependentItem)
//        }
//    }

    private func fetchData() {
        // Here we are saying that we want to fetch (or re-fetch) all items
        // and then those that pass a filter.  If you had a lot of others
        // tables in your database, you might need to divide up the fetching
        // among several groups.  For example, if you have a table of items
        // that never or rarely changes, you might not include that in this
        // fetchData method
//        fetchItems()
        fetchDestinations()
//        fetchFilteredItems()
    }

//    private func fetchFilteredItems() {
//        do {
//            // This is similar to what you can do in a View with @Query.
//            // But you can only use @Query in a View, not a ViewModel.  So here
//            // we have to build the FetchDescriptor ourselves and then run it
//            // against our ModelContext.
//
//            // This fetches Items whose title contains the letter l, and it
//            // sorts them by title.
//
//            let descriptor = FetchDescriptor<Item>(
//                predicate: #Predicate<Item> { $0.title.contains("l") },
//                sortBy: [SortDescriptor(\.title)]
//            )
//
//            filteredItems = try modelContext.fetch(descriptor)
//        } catch {
//            print("Failed to load filtered items")
//        }
//    }

//    private func fetchItems() {
//        do {
//            // In this case we want all Items, sorted by title.
//
//            let descriptor = FetchDescriptor<Destination>(sortBy: [SortDescriptor(\.name)])
//
//            items = try modelContext.fetch(descriptor)
//        } catch {
//            print("Failed to load items")
//        }
//    }
    
    private func fetchDestinations() {
        do {
            // Fetches all Destinations, sorted by name
            
            let descriptor = FetchDescriptor<Destination>(sortBy: [SortDescriptor(\.name)])
            
            destinations = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load destinations.")
        }
    }
}
