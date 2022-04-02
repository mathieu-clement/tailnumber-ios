//
//  HttpClient.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 31.03.22.
//

import Foundation
import Logging

enum RegistrationServiceError {
    case RegistrationNotFound, RegistrantNotFound, CountryNotFound, JsonError(_ error: Error), UnknownError
}

class RegistrationService: ObservableObject {

    private let basePath = "https://tailnumber-service-dev.edelweiss-software.com/registrations"

    private let jsonDecoder = JSONDecoder()

    private let logger = Logger(label: "RegistrationService")

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    func fetchTailnumbersAsync(startingWith prefix: String,
                               onResult: @escaping ([AutocompleteResult]) -> Void) {
        let url = URL(string: "\(basePath)/autocomplete/\(prefix)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        self.logger.error("Error with autocomplete: \(error.localizedDescription)")
                        Commons.alert(title: "Error", message: error.localizedDescription)
                    }
                    switch ((response as? HTTPURLResponse)?.statusCode) {
                    case 200:
                        if let data = data {
                            let results = self.decodeAutocompleteResults(fromJson: data,
                                    onFailure: { jsonError in onResult([]) } )
                            onResult(results)
                        }

                    case 404:
                        onResult([])


                    default:
                        onResult([])
                    }
                }
                .resume()
    }

    func fetchRegistrationAsync(forTailNumber tailnumber: String,
                                onSuccess: @escaping (Registration) -> Void,
                                onFailure: @escaping (RegistrationServiceError) -> Void) {
        let url = URL(string: "\(basePath)/\(tailnumber)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        self.logger.error("Error fetching registration: \(error)")
                        Commons.alert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    switch ((response as? HTTPURLResponse)?.statusCode) {
                    case 200:
                        if let data = data {
                            if let registration = self.decodeRegistration(fromJson: data, onFailure: { jsonError in
                                self.logger.error("JSON error: \(jsonError)")
                                onFailure(jsonError)
                            }
                            ) {
                                onSuccess(registration)
                            }
                        }

                    case 404:
                        onFailure(RegistrationServiceError.RegistrationNotFound)


                    default:
                        onFailure(RegistrationServiceError.UnknownError)
                    }
                }
                .resume()
    }

    private func decodeRegistration(fromJson data: Data, onFailure: @escaping (RegistrationServiceError) -> Void) -> Registration? {
        do {
            return try jsonDecoder.decode(Registration.self, from: data)
        } catch {
            // TODO handle errors better
            onFailure(RegistrationServiceError.JsonError(error))
            return nil
        }
    }

    private func decodeAutocompleteResults(fromJson data: Data, onFailure: @escaping (RegistrationServiceError) -> Void) -> [AutocompleteResult] {
        do {
            return try jsonDecoder.decode([AutocompleteResult].self, from: data)
        } catch {
            // TODO handle errors better
            onFailure(RegistrationServiceError.JsonError(error))
            return []
        }
    }
}
