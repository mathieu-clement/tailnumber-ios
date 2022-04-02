//
//  HttpModels.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 31.03.22.
//

import Foundation

struct RegistrationId: Decodable {
    enum Country: String, Decodable {
        case CH, US;

        var fullName: String {
            switch (self) {
            case .CH:
                return "Switzerland"
            case .US:
                return "United States"
            default:
                return self.rawValue
            }
        }
    }

    let id: String
    let country: Country
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
        if parts.count == 1 || parts[1].containsDigits() || parts[1].contains("c/o") {
            return parts[0]
        } else {
            return parts[0] + " " + parts[1]
        }
    }

    var aircraftName: String? {
        var result: String = ""
        var hasModel = false
        if let model = model {
            result += model
            hasModel = true
        }
        if let manufacturer = manufacturer {
            if (hasModel) {
                result += ", "
            }
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

struct Weight: Decodable {
    enum WeightUnit: String, Decodable {
        case KILOGRAMS, US_POUNDS;

        func abbreviation() -> String {
            switch (self) {
            case .KILOGRAMS:
                return "kg"
            case .US_POUNDS:
                return "lbs"
            }
        }
    }

    let value: Int
    let unit: WeightUnit

    var stringValue : String {
        "\(value.formattedWithSeparator) \(unit.abbreviation())"
    }
}

struct WeightCategory: Decodable {
    let `class`: String
    let minWeight: Weight
    let maxWeight: Weight?

    var stringValue: String {
        let class_ = `class`.starts(with: "CLASS") ? "Class \(`class`.last!)" : `class`

        if let maxWeight = maxWeight {
            if minWeight.unit != maxWeight.unit {
                return "\(class_) (\(minWeight.stringValue) - \(maxWeight.stringValue))"
            } else {
                if minWeight.value == 0 {
                    return "\(class_) (< \((maxWeight.value+1).formattedWithSeparator) \(maxWeight.unit.abbreviation()))"
                } else {
                    return "\(class_) (\(minWeight.value.formattedWithSeparator) - \(maxWeight.stringValue))"
                }
            }
        } else {
            return "\(class_) (> \(minWeight.stringValue))"
        }
    }
}

struct AircraftReference: Decodable {
    let aircraftType: String?
    let manufacturer: String?
    var manufacturer_: String? {
        if !(manufacturer?.containsLowercase() ?? false) {
            return manufacturer?.smartCapitalized
        } else {
            return manufacturer
        }
    }
    let model: String?
    let icaoType: String?
    let serialNumber: String?
    let engines: Int?
    let seats: Int?
    let passengerSeats: Int?
    let weightCategory: WeightCategory?
    let maxTakeOffMass: Weight?
    let manufactureYear: Int?
    let transponderCode: TransponderCode?
}

struct EngineReference: Decodable {
    let count: Int
    let manufacturer: String
    let model: String
}

struct TransponderCode: Decodable {
    let code: Int64
    let octal: String
    let hex: String
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

struct Airworthiness: Decodable {
    let certificateClass: String?
    let approvedOperation: [String]?
    let airworthinessDate: Date?
}

struct Registration: Decodable {
    let status: String?
    let registrationId: RegistrationId
    let aircraftReference: AircraftReference
    let engineReferences: [EngineReference]?
    let owner: String?
    let `operator`: String?
    let registrant: Registrant?
    let certificateIssueDate: Date?
    let lastActivityDate: Date?
    let expirationDate: Date?
    let airworthiness: Airworthiness?
}