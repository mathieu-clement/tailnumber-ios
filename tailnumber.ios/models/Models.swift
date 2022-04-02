//
//  Models.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 31.03.22.
//

import Foundation

struct RegistrationId : Decodable {
    enum Country: String, Decodable {
        case CH, US
    }
    
    let id: String
    let country: Country
}

extension String {
    func containsDigits() -> Bool {
        self.contains { c in c >= "0" && c <= "9" }
    }

    var smartCapitalized : String {
        get {
            lowercased().capitalized
                    .replacingOccurrences(of: "Llc", with: "LLC")
                    .replacingOccurrences(of: "Iii", with: "III")
                    .replacingOccurrences(of: "Ii", with: "II")
        }
    }
}

struct AutocompleteResult: Decodable, Identifiable, Hashable {
    var id: String {
        get {
            registrationId.id
        }
    }

    var registrantNameOrOperator: String? {
        get {
            registrant?.name.smartCapitalized ?? operatorName
        }
    }

    var operatorName: String? {
        guard `operator` != nil else {
            return nil
        }

        let parts = `operator`!.components(separatedBy: ", ")
        if parts.count == 1 || parts[1].containsDigits() || parts[1].contains("c/o") { return parts[0] }
        return parts[0] + " " + parts[1]
    }

    var aircraftName: String? {
        var result: String = ""
        var hasModel = false
        if let model = model {
            result += model
            hasModel = true
        }
        if let manufacturer = manufacturer {
            if (hasModel) { result += ", " }
            result += manufacturer.smartCapitalized
        }
        if (result.isEmpty) {
            return nil
        } else {
            return result
        }
    }

    let registrationId: RegistrationId

    let manufacturer: String?
    let model: String?
    let registrant: Registrant?
    let `operator`: String?

    static func ==(lhs: AutocompleteResult, rhs: AutocompleteResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

struct Weight : Decodable {
    enum WeightUnit: String, Decodable {
        case KILOGRAMS, POUNDS;
        
        func abbreviation() -> String {
            switch(self) {
                case .KILOGRAMS:
                    return "kg"
                case .POUNDS:
                    return "lbs"
            }
        }
    }
    
    let value: Int
    let unit: WeightUnit
}

struct AircraftReference : Decodable {
    let aircraftType: String?
    let manufacturer: String?
    let model: String?
    let icaoType: String?
    let serialNumber: String?
    let engines: Int?
    let passengerSeats: Int?
    let maxTakeOffMass: Weight?
    let manufactureYear: Int?
}

struct EngineReference: Decodable {
    let count: Int
    let manufacturer: String
    let model: String
}

struct Address: Decodable {
    let street1: String?
    let street2: String?
    let city: String?
    let zipCode: String?
    let state: String?
    let country: String?
}

struct Registrant: Decodable {
    let name: String
    let address: Address?
}

struct Registration : Decodable {
    let registrationId: RegistrationId
    let aircraftReference: AircraftReference
    let engineReferences: [EngineReference]?
    let owner: String?
    let `operator`: String?
    let registrant: Registrant?
}
