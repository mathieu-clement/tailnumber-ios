//
// Created by Mathieu Clement on 03.04.22.
//

import Foundation

class RegistrationDetailManager {

    func registrationSectionGroup(forRegistrationResult registrationResult: RegistrationResult) -> RegistrationDetailSectionGroup {
        let registration = registrationResult.registration
        var registrationRows: [RegistrationDetailRow] = []
        if registration.status != "VALID" && registration.status != "REGISTERED" {
            registrationRows.append(RegistrationDetailRow(label: "Status",
                    value: registration.status?.fromJavaEnum,
                    emphasized: true))
        }
        registrationRows.append(RegistrationDetailRow(label: "Name", value:
        registration.registrant?.name != "SALE REPORTED" && registration.registrant?.name != "REGISTRATION PENDING"
                ? registration.registrant?.name?.smartCapitalized
                : "Unknown"))
        if registration.registrant?.name?.hasSuffix("LLC") == false {
            registrationRows.append(RegistrationDetailRow(label: "Registrant type", value: registration.registrantType?.fromJavaEnum))
        }
        if let address = registration.registrant?.address {
            let addressString = toString(address: address)
            registrationRows.append(RegistrationDetailRow(
                    label: "Address",
                    value: addressString,
                    menuType: .address))
        }
        registrationRows.append(RegistrationDetailRow(label: registration.owner == registration.operator ? "Registrant" : "Owner",
                value: combineNameAndAddress(fromRegistrant: registration.owner)
//                menuType: .address // TODO enable just for the address part
        ))
        if registration.owner != registration.operator {
            registrationRows.append(RegistrationDetailRow(label: "Operator",
                    value: combineNameAndAddress(fromRegistrant: registration.operator)
                    //                menuType: .address // TODO enable just for the address part
            ))
        }
        if registration.fractionalOwnership == true {
            registrationRows.append(RegistrationDetailRow(label: "Fractional ownership", value: "Yes"))
        }
        if let coOwners = registration.coOwners {
            registrationRows.append(RegistrationDetailRow(label: "Co-owners",
                    value: coOwners
                            .map { s in
                                s.smartCapitalized
                            }
                            .joined(separator: ", ")))
        }

        var airworthiness = [registration.airworthiness?.certificateClass?.fromJavaEnum]
        if let approvedOperation = registration.airworthiness?.approvedOperation {
            airworthiness += approvedOperation.map { s in
                s.replacingOccurrences(of: "_", with: " ").lowercased()
            }
        }
        if !airworthiness.isEmpty && !airworthiness.allSatisfy({ s in s == nil }) {
            registrationRows.append(RegistrationDetailRow(label: "Airworthiness categories",
                    value: joinNotNull(airworthiness)))
        }

        registrationRows.append(RegistrationDetailRow(label: "Airworthiness date", value: registration.airworthiness?.airworthinessDate?.userLocaleFormat))
        registrationRows.append(RegistrationDetailRow(label: "Issue date", value: registration.certificateIssueDate?.userLocaleFormat))
        registrationRows.append(RegistrationDetailRow(label: "Expiration", value: registration.expirationDate?.userLocaleFormat))
//        registrationRows.append(RegistrationDetailRow(label: "Last activity", value: registration.lastActivityDate?.usFormat))
//        registrationRows.append(RegistrationDetailRow(label: "Country", value: registration.registrationId.country.fullName))

//        registrationRows.append(RegistrationDetailRow(label: "Data fetched", value: registrationResult.lastUpdate.usFormat))

        return RegistrationDetailSectionGroup(label: "Registration", systemImage: "doc.plaintext", sections: [RegistrationDetailSection(label: "Registration", rows: registrationRows)])
    }

    private func toString(address: Address) -> String {
        let cityAndState: String = joinNotNull([address.city?.smartCapitalized, address.state], separator: " ")
        let cityAndStateAndZip: String =
                (address.country != nil && address.country == "Switzerland")
                        ? "\(address.zipCode != nil ? address.zipCode! : "") \(cityAndState)"
                        : joinNotNull([cityAndState, address.zipCode])
        let fields = [address.street1?.smartCapitalized,
                      address.street2?.smartCapitalized,
                      cityAndStateAndZip,
                      address.country]
        let addressString = joinNotNull(fields, separator: "\n")
        return addressString
    }

    func aircraftSectionGroup(forRegistration registration: Registration) -> RegistrationDetailSectionGroup {
        var aircraftRows: [RegistrationDetailRow] = []
        aircraftRows.append(RegistrationDetailRow(label: "Manufacturer", value: registration.aircraftReference.manufacturer?.smartCapitalized))
        aircraftRows.append(RegistrationDetailRow(label: "Marketing designation", value: registration.aircraftReference.marketingDesignation))
        aircraftRows.append(RegistrationDetailRow(label: "Model", value: registration.aircraftReference.model))
        aircraftRows.append(RegistrationDetailRow(label: "Kit manufacturer", value: registration.aircraftReference.kitManufacturerName?.smartCapitalized))
        aircraftRows.append(RegistrationDetailRow(label: "Kit model", value: registration.aircraftReference.kitModelName))
        aircraftRows.append(RegistrationDetailRow(label: "ICAO type", value: registration.aircraftReference.icaoType))
        aircraftRows.append(RegistrationDetailRow(label: "Year", value: registration.aircraftReference.manufactureYear?.stringValue))
        aircraftRows.append(RegistrationDetailRow(label: "Category", value: registration.aircraftReference.aircraftType?.fromJavaEnum))
        aircraftRows.append(RegistrationDetailRow(label: "Class", value: registration.aircraftReference.aircraftCategory?.fromJavaEnum))
        if let certified = registration.aircraftReference.typeCertificated {
            aircraftRows.append(RegistrationDetailRow(label: "Certification", value: certified ? "Certified" : "Non-certified"))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Seats", value: registration.aircraftReference.seats?.stringValue))
        if registration.aircraftReference.passengerSeats != 0 {
            aircraftRows.append(RegistrationDetailRow(label: "Passenger seating", value: registration.aircraftReference.passengerSeats?.stringValue))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Minimum crew", value: registration.aircraftReference.minCrew?.stringValue))
        if registration.engineReferences == nil {
            aircraftRows.append(RegistrationDetailRow(label: "Number of engines", value: registration.aircraftReference.engines?.stringValue))
        }
        if let speed = registration.aircraftReference.cruisingSpeed {
            aircraftRows.append(RegistrationDetailRow(label: "Cruising speed", value: "\(speed.value) \(speed.unit.abbreviation)"))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Serial number", value: registration.aircraftReference.serialNumber))
        if let code = registration.aircraftReference.transponderCode {
            aircraftRows.append(RegistrationDetailRow(label: "Transponder code", value:
            "\(code.code) (dec)\n\(code.octal) (oct)\n\(code.hex) (hex)"))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Weight category", value: registration.aircraftReference.weightCategory?.stringValue))
        aircraftRows.append(RegistrationDetailRow(label: "Certification basis", value: registration.aircraftReference.certificationBasis))
        aircraftRows.append(RegistrationDetailRow(label: "Noise class", value: registration.aircraftReference.noiseClass))
        if let noiseLevel = registration.aircraftReference.noiseLevel {
            aircraftRows.append(RegistrationDetailRow(label: "Noise level", value: "\(noiseLevel) dB(A)"))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Legal basis", value: registration.aircraftReference.legalBasis))

        var image: String? = nil
        var systemImage: String? = nil
        switch (registration.aircraftReference.aircraftType) {
        case "HELICOPTER":
            image = "helicopter"
        case "GLIDER", "POWERED_GLIDER":
            image = "glider2"
        case "BALLOON":
            image = "balloon"
        default:
            systemImage = "airplane"
        }

        return RegistrationDetailSectionGroup(label: "Aircraft", systemImage: systemImage, image: image, sections: [RegistrationDetailSection(label: "Aircraft", rows: aircraftRows)])
    }

    func engineSectionGroup(forRegistration registration: Registration) -> RegistrationDetailSectionGroup {
        // TODO transform to have two paragraphs in the same section instead of two sections
        var results: [RegistrationDetailSection] = []
        if let engines = registration.engineReferences {
            (0..<engines.count).forEach { i in
                let engine = engines[i]
                var engineRows: [RegistrationDetailRow] = []
                if engine.count != nil && engine.count! > 1 {
                    engineRows.append(RegistrationDetailRow(label: engines.count > 1 ? "Number this type" : "Number of engines", value: engine.count?.stringValue))
                }
                if engine.count == nil && engines.count == 1 && registration.aircraftReference.engines != nil {
                    engineRows.append(RegistrationDetailRow(label: "Number of engines", value: registration.aircraftReference.engines?.stringValue))
                }
                engineRows.append(RegistrationDetailRow(label: "Manufacturer", value: engine.manufacturer.smartCapitalized))
                engineRows.append(RegistrationDetailRow(label: "Model", value: engine.model))
                engineRows.append(RegistrationDetailRow(label: "Type", value: engine.engineType?.fromJavaEnum))
                if let power = engine.power {
                    var value: Int
                    var unitAbbrev: String
                    if power.unit == .WATTS {
                        value = power.value / 1000
                        unitAbbrev = "kW"
                    } else {
                        value = power.value
                        unitAbbrev = power.unit.abbreviation
                    }
                    engineRows.append(RegistrationDetailRow(label: "Power", value: "\(value.stringValue) \(unitAbbrev)"))
                }
                if let thrust = engine.thrust {
                    var value: Int
                    var unitAbbrev: String
                    if thrust.unit == .NEWTONS {
                        value = thrust.value / 1000
                        unitAbbrev = "kN"
                    } else {
                        value = thrust.value
                        unitAbbrev = thrust.unit.abbreviation
                    }
                    engineRows.append(RegistrationDetailRow(label: "Thrust", value: "\(value.stringValue) \(unitAbbrev)"))
                }

                let sectionLabel = engines.count == 1
                        ? (engine.count != nil && engine.count! > 1 ? "Engines" : "Engine")
                        : "Engine \(i + 1)"
                results.append(RegistrationDetailSection(label: sectionLabel, rows: engineRows))
            }
        }

        return RegistrationDetailSectionGroup(label: "Engines", image: "engine", sections: results)
    }

    func propellerSectionGroup(forRegistration registration: Registration) -> RegistrationDetailSectionGroup {
        var results: [RegistrationDetailSection] = []
        if let propellers = registration.propellerReferences {
            (0..<propellers.count).forEach { i in
                let propeller = propellers[i]
                var engineRows: [RegistrationDetailRow] = []
                if propeller.count != nil && propeller.count! > 1 {
                    engineRows.append(RegistrationDetailRow(label: propellers.count > 1 ? "Number this type" : "Number of propellers", value: propeller.count?.stringValue))
                }
                engineRows.append(RegistrationDetailRow(label: "Manufacturer", value: propeller.manufacturer.smartCapitalized))
                engineRows.append(RegistrationDetailRow(label: "Model", value: propeller.model))

                let sectionLabel = propellers.count == 1
                        ? (propeller.count != nil && propeller.count! > 1 ? "Propellers" : "Propeller")
                        : "Propeller \(i + 1)"
                results.append(RegistrationDetailSection(label: sectionLabel, rows: engineRows))
            }
        }

        return RegistrationDetailSectionGroup(label: "Propellers", image: "propeller", sections: results)
    }

    private func joinNotNull(_ input: [String?], separator: String = ", ") -> String {
        ((input as [String?])
                .filter { s in
                    s != nil
                } as! [String])
                .joined(separator: separator)
    }

    private func combineNameAndAddress(fromRegistrant registrant: Registrant?) -> String? {
        guard registrant != nil else {
            return nil
        }

        var components: [String] = []
        if let name = registrant?.name {
            components.append(name)
        }
        if let address = registrant?.address {
            components.append(toString(address: address))
        }
        return components.isEmpty ? nil : components.joined(separator: "\n")
    }

    private func replaceCommasWithNewlines(_ input: String?) -> String? {
        guard input != nil else {
            return nil
        }

        var result = ""

        let parts = input!.components(separatedBy: ", ")
        var numPartsAdded = 0
        if parts.count == 1 || parts[1].containsDigits() || parts[1].contains("c/o") {
            result += parts[0]
            numPartsAdded = 1
        } else {
            result += parts[0] + " " + parts[1]
            numPartsAdded = 2
        }

        let otherParts = parts[numPartsAdded..<parts.count]
        if !otherParts.isEmpty {
            result += "\n"
            result += otherParts.joined(separator: "\n")
        }

        return result
    }
}