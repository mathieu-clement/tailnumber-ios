//
// Created by Mathieu Clement on 01.04.22.
//

import Foundation
import Logging
import SwiftUI

struct RegistrationDetailView: View {
    private let logger = Logger(label: "RegistrationDetailView")
    private let registrationService = RegistrationService()
    private let registrationDetailManager = RegistrationDetailManager()

    private let tailnumber: String

    @State private var registrationResult: RegistrationResult? = nil
    @State private var sections: [RegistrationDetailSection] = []
    @State private var lastUpdate: Date? = nil
    @State private var selectedSection = 0
    @Environment(\.presentationMode) var presentation
    private var loadingText: String = LocalizationManager().randomLoadingText()

    init(forTailnumber: String) {
        tailnumber = forTailnumber
    }

    var body: some View {
        if (registrationResult == nil) {
            ProgressView("\(loadingText)...").task {
                await fetchRegistration()
            }
        } else {
            VStack {
                Picker(selection: $selectedSection, label: Text("Section:")) {
                    ForEach(0..<sections.count, id: \.self) { i in
//                        Text(sections[i].label)
                        let section = sections[i]
                        if let image = section.image {
                            Image("\(image)_32_padded")
                                    .tag(section.label)
                        } else if let systemImage = section.systemImage {
                            Image(systemName: systemImage).tag(section.label)
                        }
                    }
                }
                        .pickerStyle(.segmented)
                        .padding([.leading, .trailing, .bottom])

                if !sections.isEmpty {
                    ScrollView {
                        let section = sections[selectedSection]
                        Text(section.label).font(.headline)
                                .padding([.bottom])
                        RegistrationDetailSectionView(label: section.label, rows: section.rows)
                        if let lastUpdate = lastUpdate {
                            Text("Last update: \(lastUpdate.userLocaleFormat)").font(.caption)
                        }
                        if let country = registrationResult?.registration.registrationId.country {
                            switch (country) {
                            case .CH:
                                Text("Source: FOCA (Switzerland)").font(.caption)
                            case .US:
                                Text("Source: FAA database").font(.caption)
                            }
                        }
                    }
                }
            }
                    .padding()
                    .navigationTitle(registrationResult?.registration.registrationId.id ?? tailnumber)
        }
    }

    private func createTable() {
        guard let registration = registrationResult?.registration else {
            sections = []
            return
        }

        sections.append(registrationDetailManager.registrationSection(forRegistrationResult: registrationResult!))
        sections.append(registrationDetailManager.aircraftSection(forRegistration: registration))
        sections += registrationDetailManager.engineSections(forRegistration: registration)
        sections += registrationDetailManager.propellerSections(forRegistration: registration)
    }

    private func fetchRegistration() async {
        logger.debug("Fetching registration async for \(tailnumber)...")

        do {
            registrationResult = try await registrationService.fetchRegistration(forTailNumber: tailnumber)
            self.lastUpdate = registrationResult?.lastUpdate
            createTable()
        } catch {
            let title: String
            let message: String
            switch (error as? RegistrationServiceError) {
            case .CountryNotFound:
                title = "Country not found"
                message = "Verify the registration starts with the country code (e.g. \"N\")"
            case .RegistrantNotFound:
                title = "No records found"
                message = "There were no records matching the query."
            case .RegistrationNotFound:
                title = "\"\(tailnumber)\" not found"
                message = "Did you include the country code (e.g. \"N\", \"HB\")?"
            default:
                title = "Unknown error"
                message = "An unknown error occurred. We are investigating it."
            }

            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: { _ in
                    presentation.wrappedValue.dismiss()
                }))
                /*
                alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
                    fetchRegistration()
                }))
                 */
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            }
        }
    }

}

