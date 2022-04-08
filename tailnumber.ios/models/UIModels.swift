
import Foundation
import SwiftUI

struct RegistrationDetailSectionGroup: Identifiable {
    var id = UUID()
    let label: String
    let systemImage: String?
    let image: String?
    let sections: [RegistrationDetailSection]

    init(label: String, systemImage: String? = nil, image: String? = nil, sections: [RegistrationDetailSection]) {
        self.label = label
        self.systemImage = systemImage
        self.image = image
        self.sections = sections
    }
}

struct RegistrationDetailSection: Identifiable {
    let label: String
    let rows: [RegistrationDetailRow]
    var id : String { label }
}

struct RegistrationDetailRow: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: String?
    var emphasized: Bool = false
    var menuType: MenuType? = nil

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: RegistrationDetailRow, rhs: RegistrationDetailRow) -> Bool {
        lhs.id == rhs.id
    }
}

enum MenuType {
    case address
}

class SearchText: ObservableObject {
    @Published var value = ""
}