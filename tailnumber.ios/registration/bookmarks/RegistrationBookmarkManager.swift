import CoreStore
import Foundation
import Logging

class RegistrationBookmarkManager {

    static var instance = RegistrationBookmarkManager()

    private let dataStack = DataStack(
            CoreStoreSchema(modelVersion: "V1", entities: [
                Entity<RegistrationBookmark>("RegistrationBookmark")
            ])
    )

    private let logger = Logger(label: "RegistrationBookmarkManager")

    private init() {
        do {
            try dataStack.addStorageAndWait(SQLiteStore())
        } catch {
            logger.error("Error initializating data stack: \(error)")
        }
    }

    func addBookmark(registration: Registration) {
        do {
            try dataStack.perform(asynchronous: { (transaction) in
                let bookmark = transaction.create(Into<RegistrationBookmark>())
                bookmark.tailnumber = registration.registrationId.id
                bookmark.manufacturer = registration.aircraftReference.manufacturer
                bookmark.model = registration.aircraftReference.model
                bookmark.year = registration.aircraftReference.manufactureYear
            }, completion: { _ in })
        } catch {
            logger.error("Error bookmarking registration: \(error)")
        }
    }

    func removeBookmark(tailnumber: String) {
        do {
            try dataStack.perform(asynchronous: { (transaction) in
                try transaction.deleteAll(
                        From<RegistrationBookmark>(),
                        Where<RegistrationBookmark>(\.$tailnumber == tailnumber)
                )
            }, completion: { _ in })
        } catch {
            logger.error("Error removing bookmark: \(error)")
        }
    }

    func isBookmarked(tailnumber: String) -> Bool {
        do {
            return try dataStack.fetchCount(From<RegistrationBookmark>().where(\.$tailnumber == tailnumber)) > 0
        } catch {
            logger.error("Error fetching isBookmarked: \(error)")
            return false
        }
    }
}
