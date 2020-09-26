//
//  RealmHelper.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

struct Constants {
    static let appVersion: String = {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            else { fatalError("Info.plist does not contain CFBundleShortVersionString") }
        return version
    }()

    static let realmAppId: String = {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "REALM_APP_ID") as? String
            else { fatalError("Info.plist does not contain REALM_APP_ID") }
        return version
    }()
}

let app = App(id: Constants.realmAppId)

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
        } catch {
            print("REALM ERROR:", error.localizedDescription)
        }
    }
}

extension Object {
    static func load(from id: String) -> Self? {
        let realm = try? Realm()
        return realm?.object(ofType: Self.self, forPrimaryKey: id)
    }
}

// MARK: - RealmHelpter
/// The helper is just a CRUD simplification for Realm with support for RealmConvertible protocol
struct RealmHelper {
    let realm: Realm

    init() { realm = try! Realm() }

    func create<O: Object>(_ o: O) {
        do {
            try realm.write {
                realm.add(o)
            }
        }
        catch {
            print("REALM ADD ERROR:", error.localizedDescription)
        }
    }

    func update<O: Object>(o: O) {
        do {
            try realm.write {
                realm.create(O.self, value:o, update: .modified)
            }
        }
        catch {
            print("REALM CREATE ERROR:", error.localizedDescription)
        }
    }

    func updateConvertible<C: RealmConvertible>(_ c: C) {
        do {
            try realm.write {
                realm.create(C.RealmType.self, value: c.realmMap(), update: .modified)
            }
        }
        catch {
            print("REALM CREATE ERROR:", error.localizedDescription)
        }
    }

    func get<O: Object & ObjectIdentifiable>(_ o: O) -> O? {
        realm.object(ofType: O.self, forPrimaryKey: o.id)
    }

    func delete<O: Object & ObjectIdentifiable>(_ o: O) {
        if let d = get(o) {
            do {
                try realm.write {
                    realm.delete(d)
                }
            }
            catch {
                print("REALM DELETE ERROR:", error.localizedDescription)
            }
        }
    }

    func list<O: Object>(_ o: O.Type) -> RealmSwift.Results<O> {
        realm.objects(o)
    }
}
