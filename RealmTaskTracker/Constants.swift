//
//  Constants.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 10/24/20.
//

import Foundation

struct Constants {
    static let partitionValue = "SharedPartition"

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
