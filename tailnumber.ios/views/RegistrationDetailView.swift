//
// Created by Mathieu Clement on 01.04.22.
//

import Foundation
import Logging
import SwiftUI

struct RegistrationDetailView: View {
    private let logger = Logger(label: "RegistrationDetailView")
    private let registrationService = RegistrationService()

    private let tailnumber: String

    @State private var registration: Registration? = nil
    @State private var sections: [RegistrationDetailSection] = []
    @State private var selectedSection = 0
    @Environment(\.presentationMode) var presentation
    private static var loadingTexts = [
        "Priming the engine",
        "Fetching data",
        "Spooling up the engines",
        "Tuning in the frequency"
    ]
    private var loadingText : String = loadingTexts[Int.random(in: 0..<loadingTexts.count)]

    init(forTailnumber: String) {
        tailnumber = forTailnumber
    }

    var body: some View {
        if (registration == nil) {
            Text("\(loadingText)...").onAppear {
                fetchRegistration()
            }
        } else {
            VStack {
                Picker(selection: $selectedSection, label: Text("Section:")) {
                    ForEach(0..<sections.count, id: \.self) { i in
                        Text(sections[i].label)
                    }
                }
                        .pickerStyle(.segmented)
                        .padding()

                if !sections.isEmpty {
                    let section = sections[selectedSection]
                    RegistrationDetailSectionView(label: section.label, rows: section.rows)
                    Spacer()
                }
            }
                    .padding()
                    .navigationTitle(registration?.registrationId.id ?? tailnumber)
        }
    }

    private func createTable() {
        guard let registration = registration else {
            sections = []
            return
        }


        var registrationRows: [RegistrationDetailRow] = []
        if registration.status != "VALID" {
            registrationRows.append(RegistrationDetailRow(label: "Status", value: registration.status?.lowercased().capitalized))
        }
        registrationRows.append(RegistrationDetailRow(label: "Name", value: registration.registrant?.name.smartCapitalized))
        if let address = registration.registrant?.address {
            let cityAndState: String = joinNotNull([address.city?.smartCapitalized, address.state], separator: " ")
            let cityAndStateAndZip: String = joinNotNull([cityAndState, address.zipCode])
            let fields = [address.street1?.smartCapitalized, address.street2?.smartCapitalized,
                          cityAndStateAndZip, address.country]
            registrationRows.append(RegistrationDetailRow(label: "Address", value: joinNotNull(fields, separator: "\n")))
        }
        if (registration.owner == registration.operator) {
            registrationRows.append(RegistrationDetailRow(label: "Registrant", value: replaceCommasWithNewlines(registration.owner)))
        } else {
            registrationRows.append(RegistrationDetailRow(label: "Owner", value: replaceCommasWithNewlines(registration.owner)))
            registrationRows.append(RegistrationDetailRow(label: "Operator", value: replaceCommasWithNewlines(registration.operator)))
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

        registrationRows.append(RegistrationDetailRow(label: "Airworthiness date", value: registration.airworthiness?.airworthinessDate?.usFormat))
        registrationRows.append(RegistrationDetailRow(label: "Issue date", value: registration.certificateIssueDate?.usFormat))
        registrationRows.append(RegistrationDetailRow(label: "Last activity", value: registration.lastActivityDate?.usFormat))
        registrationRows.append(RegistrationDetailRow(label: "Expiration", value: registration.expirationDate?.usFormat))
//        registrationRows.append(RegistrationDetailRow(label: "Country", value: registration.registrationId.country.fullName))
        sections.append(RegistrationDetailSection(label: "Registration", rows: registrationRows))

        var aircraftRows: [RegistrationDetailRow] = []
        aircraftRows.append(RegistrationDetailRow(label: "Manufacturer", value: registration.aircraftReference.manufacturer?.smartCapitalized))
        aircraftRows.append(RegistrationDetailRow(label: "Model", value: registration.aircraftReference.model))
        aircraftRows.append(RegistrationDetailRow(label: "Year", value: registration.aircraftReference.manufactureYear?.stringValue))
        aircraftRows.append(RegistrationDetailRow(label: "Aircraft type", value: registration.aircraftReference.aircraftType?.fromJavaEnum))
        aircraftRows.append(RegistrationDetailRow(label: "Serial number", value: registration.aircraftReference.serialNumber))
        aircraftRows.append(RegistrationDetailRow(label: "Seats", value: registration.aircraftReference.seats?.stringValue))
        if registration.aircraftReference.passengerSeats != 0 {
            aircraftRows.append(RegistrationDetailRow(label: "Passenger seating", value: registration.aircraftReference.passengerSeats?.stringValue))
        }
        if registration.engineReferences == nil {
            aircraftRows.append(RegistrationDetailRow(label: "Number of engines", value: registration.aircraftReference.engines?.stringValue))
        }
        aircraftRows.append(RegistrationDetailRow(label: "Weight category", value: registration.aircraftReference.weightCategory?.stringValue))
        sections.append(RegistrationDetailSection(label: "Aircraft", rows: aircraftRows))

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
                        : "Engine type \(i+1)"
                sections.append(RegistrationDetailSection(label: sectionLabel, rows: engineRows))
            }
        }
    }

    private func joinNotNull(_ input: [String?], separator: String = ", ") -> String {
        ((input as [String?])
                .filter { s in
                    s != nil
                } as! [String])
                .joined(separator: separator)
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

    private func fetchRegistration() {
        logger.debug("Fetching registration async for \(tailnumber)...")

        registrationService.fetchRegistrationAsync(forTailNumber: tailnumber,
                onSuccess: { reg in
                    DispatchQueue.main.async {
                        self.registration = reg
                        createTable()
                    }
                },
                onFailure: { error in
                    let title: String
                    let message: String
                    switch (error) {
                    case .CountryNotFound:
                        title = "Country not found"
                        message = "Verify the registration starts with the country code (e.g. \"N\")"
                    case .RegistrantNotFound:
                        title = "No records found"
                        message = "There were no records matching the query."
                    case .RegistrationNotFound:
                        title = "Registration not found"
                        message = "Verify the tail number is correct and starts with the country code (e.g. \"N\")"
                    default:
                        title = "Unknown error"
                        message = "An unknown error occurred. We are investigating it."
                    }

                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: { _ in
                            presentation.wrappedValue.dismiss()
                        }))
                        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
                            fetchRegistration()
                        }))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                    }
                })
    }

}

struct Previews_RegistrationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationDetailView(forTailnumber: "N12234")
    }
}
