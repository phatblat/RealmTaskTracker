//
//  RealmHelper.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

extension Realm {
    static func create(_ data: Object) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(data)
        }
    }

    static func destroyAllData() {
        try! FileManager.default.removeItem(at: Self.Configuration.defaultConfiguration.fileURL!)
    }

    static func clearAllData() {
        do {
            let realm = try? Self()
            try realm?.write {
                realm?.deleteAll()
            }
        } catch let e {
            print("REALM ERR:", e.localizedDescription)
        }
    }
}

extension Object {
    static func load(from id: String) -> Self? {
        let realm = try? Realm()
        return realm?.object(ofType: Self.self, forPrimaryKey: id)
    }
}

protocol UUIDIdentifiable: Identifiable { var id: String { get } }
protocol Initializable { init() }

// MARK: - RealmHelpter
/// The helper is just a CRUD simplification for Realm with support for RealmConvertible protocol
struct RealmHelper {
    let realm: Realm

    init() { realm = try! Realm() }

    func create<O: Object>(_ o: O) {
        try? realm.write {
            realm.add(o)
        }
    }

    func update<O: Object>(o: O) {
        try? realm.write {
            realm.create(O.self, value:o, update: .modified)
        }
    }

    func updateConvertible<C: RealmConvertible>(_ c: C) {
        try? realm.write {
            realm.create(C.RealmType.self, value:c.realmMap(), update: .modified)
        }
    }

    func get<O: Object & UUIDIdentifiable>(_ o: O) -> O? {
        realm.object(ofType: O.self, forPrimaryKey: o.id)
    }

    func delete<O: Object & UUIDIdentifiable>(_ o: O) {
        if let d = get(o) {
            try? realm.write {
                realm.delete(d)
            }
        }
    }

    func list<O: Object>(_ o: O.Type) -> RealmSwift.Results<O> {
        realm.objects(o)
    }
}
