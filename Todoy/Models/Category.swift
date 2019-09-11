//
//  Category.swift
//  Todoey
//
//  Created by Eric on 9/6/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    var items = List<Item>()
}
