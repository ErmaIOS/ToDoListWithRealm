//
//  ToDoListViewModel.swift
//  ToDoListWithRealm
//
//  Created by Erma on 31/7/24.
//

import Foundation
import RealmSwift
import Combine

class ToDoListViewModel {
    private let realm = try! Realm()
    
    @Published var tasks: Results<Tasks>?
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        tasks = realm.objects(Tasks.self)
    }
    
    func addTask(_ task: Tasks) throws {
        try realm.write {
            realm.add(task)
        }
        fetchTasks()
    }
    
    func deleteTask(_ task: Tasks) throws {
        try realm.write {
            realm.delete(task)
        }
        fetchTasks()
    }
    
    func deleteAllTasks() throws {
        try realm.write {
            realm.deleteAll()
        }
        fetchTasks()
    }
}
