//
// Created by Mathieu Clement on 01.04.22.
//

import Foundation
import SwiftUI

struct RegistrationDetailView: View {
    private let registrationService = RegistrationService()

    private let tailnumber: String

    @State private var registration: Registration? = nil

    init(forTailnumber: String) {
        tailnumber = forTailnumber
    }

    var body: some View {
        VStack {
            if let registration = registration {
                Text(registration.aircraftReference.manufacturer!)
                Text(registration.aircraftReference.model!)
                Text(String(registration.aircraftReference.manufactureYear!))
            }
        }
                .onAppear {
                    fetchRegistration()
                }
    }

    func fetchRegistration() {
        print("Fetching registration async for \(tailnumber)...")
        registrationService.fetchRegistrationAsync(forTailNumber: tailnumber,
                onSuccess: { reg in
                    print("\(tailnumber) / \(reg.registrationId.id).manufacturer= \(reg.aircraftReference.model!)")
                    DispatchQueue.main.async {
                        self.registration = reg
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
                        alert.addAction(UIAlertAction(title: "OK", style: .destructive))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                    }
                })
    }
}
