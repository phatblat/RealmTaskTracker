//
//  SyncLogLevel+Name.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 8/9/21.
//

import RealmSwift

/// RLMSyncLogLevel case names
extension SyncLogLevel {
    var name: String {
        switch self {
        case .off: return "off"
        case .fatal: return "fatal"
        case .error: return "error"
        case .warn: return "warn"
        case .info: return "info"
        case .detail: return "detail"
        case .debug: return "debug"
        case .trace: return "trace"
        case .all: return "all"
        }
    }
}
