//
//  HttpClient.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 31.03.22.
//

import Foundation
import Logging

enum RegistrationServiceError: Error {
    case RegistrationNotFound, RegistrantNotFound, CountryNotFound, JsonError(_ error: Error), UnknownError
}

class RegistrationService: ObservableObject {

    private let basePath = "https://tailnumber-service-dev.edelweiss-software.com/registrations"
    private let jsonDecoder = JSONDecoder()
    private let logger = Logger(label: "RegistrationService")
    private var debounce_timer: Timer?

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    func autocompleteTailnumberOrRegistrant(tailNumberOrRegistrant prefix: String) async -> [AutocompleteResult] {
        if (prefix.isEmpty) {
            return []
        }
        guard let prefixParam = prefix.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            logger.error("Prefix param was nil?? : \(prefix)")
            return []
        }
        let urlString = "\(basePath)/any/\(prefixParam)"
        guard let url = URL(string: urlString) else {
            logger.error("Unwrapping url was nil?? : \(urlString)")
            return []
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            switch ((response as? HTTPURLResponse)?.statusCode) {
            case 200:
                let results = try decodeAutocompleteResults(fromJson: data)
                if results.isEmpty {
                    logger.warning("Something must have gone wrong. 200 status but empty results.")
                }
                return results

            case 404:
                return []

            default:
                throw RegistrationServiceError.UnknownError
            }
        } catch {
            logger.error("Error with autocomplete: \(error)")
//                Commons.alert(title: "Error", message: error.localizedDescription) { }
            return []
        }
    }

    @MainActor
    func fetchRegistration(forTailNumber tailnumber: String) async throws -> RegistrationResult? {
        let urlOpt = URL(string: "\(basePath)/\(tailnumber)")
        guard let url = urlOpt else {
            logger.error("Empty URL?!")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            switch ((response as? HTTPURLResponse)?.statusCode) {
            case 200:
                return try decodeRegistrationResult(fromJson: data)

            case 404:
                throw RegistrationServiceError.RegistrationNotFound

            default:
                throw RegistrationServiceError.UnknownError
            }
        } catch {
            logger.error("Error fetching registration: \(error)")
            Commons.alert(title: "Error", message: error.localizedDescription) {
            }
            throw error
        }
    }

    private func decodeRegistrationResult(fromJson data: Data) throws -> RegistrationResult? {
        do {
            return try jsonDecoder.decode(RegistrationResult.self, from: data)
        } catch {
            self.logger.error("JSON error: \(error)")
            throw RegistrationServiceError.JsonError(error)
        }
    }

    private func decodeAutocompleteResults(fromJson data: Data) throws -> [AutocompleteResult] {
        do {
            return try jsonDecoder.decode([AutocompleteResult].self, from: data)
        } catch {
            logger.error("Error decoding autocomplete result: \(error)")
            throw RegistrationServiceError.JsonError(error)
        }
    }
}
