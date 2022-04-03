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

        sections.append(registrationDetailManager.registrationSection(forRegistration: registration))
        sections.append(registrationDetailManager.aircraftSection(forRegistration: registration))
        sections += registrationDetailManager.engineSections(forRegistration: registration)
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

