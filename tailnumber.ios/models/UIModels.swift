//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation

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
}