
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
            registrant?.name?.smartCapitalized ?? operatorName
        }
    }

    var operatorName: String? {
        guard `operator`?.name != nil else {
            return nil
        }

        let parts = `operator`!.name!.components(separatedBy: ", ")
        if parts.count == 1 || parts[1].containsDigits() || parts[1].contains("c/o") {
            return parts[0]
        } else {
            return parts[0] + " " + parts[1]
        }
    }

    static func composeAircraftName(manufacturer: String?, model: String?, year: Int?) -> String? {
        var components: [String] = []

        if let model = model {
            components.append(model)
        }
        if let manufacturer = manufacturer {
            components.append(manufacturer.smartCapitalized)
        }
        if let year = year {
            components.append(year.stringValue)
        }

        if components.isEmpty {
            return nil
        } else {
            return components.joined(separator: ", ")
        }
    }

    var aircraftName: String? {
        Self.composeAircraftName(manufacturer: manufacturer, model: model, year: year)
    }

    let registrationId: RegistrationId

    let manufacturer: String?
    let model: String?
    let year: Int?
    let registrant: Registrant?
    let `operator`: Registrant?

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

        var abbreviation: String {
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
        "\(value.formattedWithSeparator) \(unit.abbreviation)"
    }
}

struct WeightCategory: Decodable {
    let `class`: String
    let minWeight: Weight
    let maxWeight: Weight?

    var stringValue: String {
        if let maxWeight = maxWeight {
            if minWeight.unit != maxWeight.unit {
                return "\(minWeight.stringValue) - \(maxWeight.stringValue)"
            } else {
                if minWeight.value == 0 {
                    return "< \((maxWeight.value+1).formattedWithSeparator) \(maxWeight.unit.abbreviation)"
                } else {
                    return "\(minWeight.value.formattedWithSeparator) - \(maxWeight.stringValue)"
                }
            }
        } else {
            return "> \(minWeight.stringValue)"
        }
    }
}

struct AircraftReference: Decodable {
    let aircraftType: String?
    let aircraftCategory: String?
    let manufacturer: String?
    let model: String?
    let marketingDesignation: String?
    let icaoType: String?
    let serialNumber: String?
    let engines: Int?
    let seats: Int?
    let passengerSeats: Int?
    let weightCategory: WeightCategory?
    let typeCertificated: Bool?
    let cruisingSpeed: Speed?
    let maxTakeOffMass: Weight?
    let manufactureYear: Int?
    let transponderCode: TransponderCode?
    let kitManufacturerName: String?
    let kitModelName: String?
    let certificationBasis: String?
    let minCrew: Int?
    let noiseClass: String?
    let noiseLevel: Double?
    let legalBasis: String?
}

struct EngineReference: Decodable {
    let count: Int?
    let manufacturer: String
    let model: String
    let engineType: String?
    let power: Power?
    let thrust: Thrust?
}

struct PropellerReference: Decodable {
    let count: Int?
    let manufacturer: String
    let model: String
}

struct Speed: Decodable {
    let value: Int
    let unit: SpeedUnit
}

enum SpeedUnit: String, Decodable {
    case KT, MPH, KPH;

    var abbreviation: String {
        switch (self) {
        case .KT:
            return "kt"
        case .MPH:
            return "mph"
        case .KPH:
            return "kph"
        }
    }
}

struct Power: Decodable {
    let value: Int
    let unit: PowerUnit
}

enum PowerUnit: String, Decodable {
    case SAE_HP, METRIC_HP, WATTS;

    var abbreviation: String {
        switch (self) {
        case .SAE_HP:
            return "hp"
        case .METRIC_HP:
            return "hp (metric)"
        case .WATTS:
            return "W"
        }
    }
}

struct Thrust: Decodable {
    let value: Int
    let unit: ThrustUnit
}

enum ThrustUnit: String, Decodable {
    case POUNDS, NEWTONS;

    var abbreviation: String {
        switch (self) {
        case .POUNDS:
            return "lbs"
        case .NEWTONS:
            return "N"
        }
    }
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

struct Registrant: Decodable, Equatable {
    static func ==(lhs: Registrant, rhs: Registrant) -> Bool {
        lhs.id == rhs.id
    }

    let name: String?
    let address: Address?
    let id: Int64

    enum CodingKeys: String, CodingKey {
        case id = "uniqueId"
        case name, address
    }
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
    let propellerReferences: [PropellerReference]?
    let owner: Registrant?
    let `operator`: Registrant?
    let registrant: Registrant?
    let registrantType: String?
    let certificateIssueDate: Date?
    let lastActivityDate: Date?
    let expirationDate: Date?
    let airworthiness: Airworthiness?
    let fractionalOwnership: Bool?
    let coOwners: [String]?
}

struct RegistrationResult: Decodable {
    let lastUpdate: Date
    let registration: Registration
}