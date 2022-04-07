//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation
import SwiftUI

struct RegistrationDetailSection: Identifiable {
    let label: String
    let image: String
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