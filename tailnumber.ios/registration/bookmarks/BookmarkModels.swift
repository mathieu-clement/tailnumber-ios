import CoreStore
import Foundation

class RegistrationBookmark: CoreStoreObject {
    @Field.Stored("tailnumber")
    var tailnumber: String = ""

    @Field.Stored("manufacturer")
    var manufacturer: String? = nil

    @Field.Stored("model")
    var model: String? = nil

    @Field.Stored("year")
    var year: Int? = nil

    @Field.Stored("registrantName")
    var registrantName: String? = nil

    @Field.Stored("dateAdded")
    var dateAdded: Date = Date()
}