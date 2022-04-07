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
    private var debounce_timer : Timer?

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    func autocompleteTailnumberOrRegistrant(tailNumberOrRegistrant prefix: String,
                                            onResult: @escaping ([AutocompleteResult]) -> Void) {
        debounce_timer?.invalidate()
        debounce_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [self] _ in
            if (prefix.isEmpty) {
                onResult([])
                return
            }
            guard let prefixParam = prefix.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                logger.error("Prefix param was nil?? : \(prefix)")
                onResult([])
                return
            }
            let urlString = "\(basePath)/any/\(prefixParam)"
            guard let url = URL(string: urlString) else {
                logger.error("Unwrapping url was nil?? : \(urlString)")
                onResult([])
                return
            }
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            self.logger.error("Error with autocomplete: \(error)")
                            Commons.alert(title: "Error", message: error.localizedDescription) { }
                        }
                        switch ((response as? HTTPURLResponse)?.statusCode) {
                        case 200:
                            if let data = data {
                                let results = decodeAutocompleteResults(fromJson: data,
                                        onFailure: { jsonError in onResult([]) } )
                                if results.isEmpty {
                                    self.logger.warning("Something must have gone wrong. 200 status but empty results.")
                                }
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
    }

    func fetchRegistrationAsync(forTailNumber tailnumber: String,
                                onSuccess: @escaping (RegistrationResult) -> Void,
                                onFailure: @escaping (RegistrationServiceError) -> Void) {
        let urlOpt = URL(string: "\(basePath)/\(tailnumber)")
        guard let url = urlOpt else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        self.logger.error("Error fetching registration: \(error)")
                        Commons.alert(title: "Error", message: error.localizedDescription) { }
                        return
                    }
                    switch ((response as? HTTPURLResponse)?.statusCode) {
                    case 200:
                        if let data = data {
                            if let registrationResult = self.decodeRegistrationResult(fromJson: data, onFailure: { jsonError in
                                self.logger.error("JSON error: \(jsonError)")
                                onFailure(jsonError)
                            }
                            ) {
                                onSuccess(registrationResult)
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

    private func decodeRegistrationResult(fromJson data: Data, onFailure: @escaping (RegistrationServiceError) -> Void) -> RegistrationResult? {
        do {
            return try jsonDecoder.decode(RegistrationResult.self, from: data)
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
            logger.error("Error decoding autocomplete result: \(error)")
            onFailure(RegistrationServiceError.JsonError(error))
            return []
        }
    }
}
