//
//  AppState.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Combine
import Foundation

/// Core app logic including Realm app and Combine publishers. No longer used.
/// TODO: Move syng logging and error handling to 
final class AppState {
    /// Cancellables to be retained for any Future.
    var cancellables = Set<AnyCancellable>()

    /// Token for upload progress notification block.
    var uploadProgressToken: SyncSession.ProgressNotificationToken?

    /// Token for download progress notification block.
    var downloadProgressToken: SyncSession.ProgressNotificationToken?

    /// The Realm sync app.
    private let app: RealmSwift.App = {
        let app = RealmSwift.App(id: Constants.realmAppId)
        let syncManager = app.syncManager
        syncManager.logLevel = .info
        syncManager.logger = { (level: SyncLogLevel, message: String) in
            print("[\(level.name)] Sync - \(message)")
        }
        syncManager.errorHandler = { (error, session) in
            print("Sync Error: \(error)")
            // https://docs.realm.io/sync/using-synced-realms/errors
            if let syncError = error as? SyncError {
                switch syncError.code {
                case .permissionDeniedError:
                    // HTTP/1.1 401 Unauthorized
//                    shouldIndicateActivity = false
                    _ = app.currentUser?.logOut()
                        .sink(receiveCompletion: {
                            print($0)
                        }, receiveValue: {
                            print("receive value")
                        })
                case .clientResetError:
                    if let (path, clientResetToken) = syncError.clientResetInfo() {
                        // TODO: close and backup
                        //closeRealmSafely()
                        //saveBackupRealmPath(path)
                        SyncSession.immediatelyHandleError(clientResetToken, syncManager: app.syncManager)
                    }
                default:
                    ()
                }
            }
            if let session = session {
                print("Sync Session: \(session)")
            }
        }
        return app
    }()

    init() {
        // Create a private subject for the opened realm, so that:
        // - if we are not using Realm Sync, we can open the realm immediately.
        // - if we are using Realm Sync, we can open the realm later after login.
        let realmPublisher = PassthroughSubject<Realm, Error>()

        // Specify what to do when the realm opens, regardless of whether
        // we're authenticated and using Realm Sync or not.
        realmPublisher
            .sink(receiveCompletion: { result in
                // Check for failure.
                if case let .failure(error) = result {
                    print("Failed to log in and open realm: \(error.localizedDescription)")
                }
            }, receiveValue: { realm in
                // The realm has successfully opened.
                let syncSession = realm.syncSession!

                // Observe using Combine
                syncSession.publisher(for: \.connectionState)
                    .sink { connectionState in
                        switch connectionState {
                        case .connecting:
                            print("Sync Connecting...")
                        case .connected:
                            print("Sync Connected")
                        case .disconnected:
                            print("Sync Disconnected")
                        default:
                            break
                        }
                    }
                    .store(in: &self.cancellables)

                self.downloadProgressToken = syncSession.addProgressNotification(
                    for: .download, mode: .forCurrentlyOutstandingWork)
                { (progress) in
                    let transferredBytes = progress.transferredBytes
                    let transferrableBytes = progress.transferrableBytes
                    let transferPercent = progress.fractionTransferred * 100
                    print("Sync Downloaded \(transferredBytes)B / \(transferrableBytes)B (\(transferPercent)%)")
                }

                self.uploadProgressToken = syncSession.addProgressNotification(
                    for: .upload, mode: .forCurrentlyOutstandingWork)
                { (progress) in
                    let transferredBytes = progress.transferredBytes
                    let transferrableBytes = progress.transferrableBytes
                    let transferPercent = progress.fractionTransferred * 100
                    print("Sync Uploaded \(transferredBytes)B / \(transferrableBytes)B (\(transferPercent)%)")
                }
            })
            .store(in: &cancellables)
    }
}

