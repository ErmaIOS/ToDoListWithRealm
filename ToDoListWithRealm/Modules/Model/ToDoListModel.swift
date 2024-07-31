//
//  ToDoListModel.swift
//  ToDoListWithRealm
//
//  Created by Erma on 31/7/24.
//

import UIKit
import RealmSwift

class Tasks: Object {
    @objc dynamic var task = ""
    @objc dynamic var completed = false
}
