//import CoreData
//import SwiftUI
//
//class PersistenceController: ObservableObject {
//    static let shared = PersistenceController()
//    
//    let container: NSPersistentContainer
//    
//    private init() {
//        container = NSPersistentContainer(name: "TXTReader")
//        
//        // 配置存储
//        let description = NSPersistentStoreDescription()
//        description.type = NSSQLiteStoreType
//        description.shouldMigrateStoreAutomatically = true
//        description.shouldInferMappingModelAutomatically = true
//        
//        container.persistentStoreDescriptions = [description]
//        
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                print("Core Data加载失败: \(error.localizedDescription)")
//                let nsError = error as NSError
//                print("Unresolved error \(nsError), \(nsError.userInfo)")
//                fatalError("无法加载Core Data存储: \(error.localizedDescription)")
//            }
//            
//            print("Core Data存储加载成功: \(description.url?.absoluteString ?? "unknown")")
//        }
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        container.viewContext.shouldDeleteInaccessibleFaults = true
//    }
//    
//    func save() {
//        let context = container.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//                objectWillChange.send()
//            } catch {
//                let nsError = error as NSError
//                print("保存Core Data失败: \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//    
//    func deleteAll() {
//        let context = container.viewContext
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Book")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        deleteRequest.resultType = .resultTypeObjectIDs
//        
//        do {
//            let result = try container.persistentStoreCoordinator.execute(deleteRequest, with: context) as? NSBatchDeleteResult
//            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
//            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
//            objectWillChange.send()
//        } catch {
//            print("删除所有数据失败: \(error)")
//        }
//    }
//} 
