import CoreStore
import Foundation
import SwiftUI

struct RegistrationBookmarkListView: View {

    private let bookmarks: ListPublisher<RegistrationBookmark> = RegistrationBookmarkManager.instance.listPublisher

    var body: some View {
        ListReader(bookmarks) { snapshot in
            if !snapshot.isEmpty {
                Text("Bookmarks").font(.title2)
            }
            List {
                ForEach(objectIn: snapshot) { (bookmark: ObjectPublisher<RegistrationBookmark>) in
                    let tailnumber = bookmark.tailnumber!
                    let manufacturer = bookmark.manufacturer!
                    let model = bookmark.model!
                    let year = bookmark.year!
                    let registrantName = bookmark.registrantName!

                    let detailView = RegistrationDetailView(forTailnumber: tailnumber)
                    NavigationLink(destination: detailView) {
                        VStack(alignment: .leading) {
                            Text(tailnumber).font(.subheadline)
                            if let aircraftName = AutocompleteResult.composeAircraftName(
                                    manufacturer: manufacturer, model: model, year: year) {
                                Text(aircraftName).font(.caption).foregroundColor(.gray)
                            }
                            if let name = registrantName {
                                Text(name).font(.caption2).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
//                .animation(.default)
    }
}