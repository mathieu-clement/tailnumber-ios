
import Foundation
import Logging
import SwiftUI

struct RegistrationDetailView: View {
    private let logger = Logger(label: "RegistrationDetailView")
    private let registrationService = RegistrationService()
    private let registrationDetailManager = RegistrationDetailManager()
    private let bookmarkManager = RegistrationBookmarkManager.instance

    private let tailnumber: String

    @State private var registrationResult: RegistrationResult? = nil
    @State private var sectionGroups: [RegistrationDetailSectionGroup] = []
    @State private var lastUpdate: Date? = nil
    @State private var selectedSection = 0
    @State private var isBookmarked = false
    @Environment(\.presentationMode) var presentation
    private var loadingText: String = LocalizationManager().randomLoadingText()

    init(forTailnumber: String) {
        tailnumber = forTailnumber
    }

    var body: some View {
        if (registrationResult == nil) {
            ProgressView("\(loadingText)...").task {
                await fetchRegistration()
                fetchIsBookmarked()
            }
        } else {
            VStack {
                Picker(selection: $selectedSection, label: Text("Section:")) {
                    ForEach(0..<sectionGroups.count, id: \.self) { i in
//                        Text(sections[i].label)
                        let sectionGroup = sectionGroups[i]
                        if let image = sectionGroup.image {
                            Image("\(image)_32_padded")
                                    .tag(sectionGroup.label)
                        } else if let systemImage = sectionGroup.systemImage {
                            Image(systemName: systemImage).tag(sectionGroup.label)
                        }
                    }
                }
                        .pickerStyle(.segmented)
                        .padding([.leading, .trailing, .bottom])

                if !sectionGroups.isEmpty {
                    ScrollView {

                        ForEach(0..<sectionGroups[selectedSection].sections.count, id: \.self) { i in
                            let section = sectionGroups[selectedSection].sections[i]
                            if i == 0 {
                                Text(section.label)
                                        .font(.headline)
                                        .padding([.bottom])
                            } else {
                                Text(section.label)
                                        .font(.headline)
                                        .padding([.bottom, .top])
                            }
                            RegistrationDetailSectionView(label: section.label, rows: section.rows)
                        }

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
                    .toolbar {
                        if isBookmarked {
                            Image(systemName: "star.fill")
                                    .foregroundColor(.accentColor)
                                    .onTapGesture {
                                        bookmarkManager.removeBookmark(tailnumber: tailnumber)
                                        isBookmarked = false
                                    }
                        } else {
                            Image(systemName: "star")
                                    .foregroundColor(.accentColor)
                                    .onTapGesture {
                                        if let registration = registrationResult?.registration {
                                            bookmarkManager.addBookmark(registration: registration)
                                            isBookmarked = true
                                        }
                                    }
                        }
                    }
        }
    }

    private func createTable() {
        guard let registration = registrationResult?.registration else {
            sectionGroups = []
            return
        }

        sectionGroups = []

        addSection(group: registrationDetailManager.registrationSectionGroup(forRegistrationResult: registrationResult!))
        addSection(group: registrationDetailManager.aircraftSectionGroup(forRegistration: registration))
        addSection(group: registrationDetailManager.engineSectionGroup(forRegistration: registration))
        addSection(group: registrationDetailManager.propellerSectionGroup(forRegistration: registration))
    }

    private func addSection(group: RegistrationDetailSectionGroup) {
        if !group.sections.isEmpty {
            sectionGroups.append(group)
        }
    }

    private func fetchIsBookmarked() {
        self.isBookmarked = bookmarkManager.isBookmarked(tailnumber: tailnumber)
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

