//
//  ContentView.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 30.03.22.
//

import SwiftUI

struct SearchView: View {
    private let registrationService = RegistrationService()
    @State private var tailnumber: String = ""
    @State private var autocompleteResults: [AutocompleteResult] = []
    @State private var model: String = ""

    var body: some View {
        let tailnumberBinding = Binding<String>(get: { tailnumber }, set: {
            tailnumber = $0.uppercased()
            if tailnumber.count > 2 {
                onKeyPressed()
            } else {
                autocompleteResults = []
            }
        })

        NavigationView {
            List(autocompleteResults, id: \.self) { result in
                let detailView = RegistrationDetailView(forTailnumber: result.registrationId.id)
                NavigationLink(destination: detailView) {
                    VStack(alignment: .leading) {
                        Text(result.registrationId.id).font(.subheadline)
                        if let aircraftName = result.aircraftName {
                            Text(aircraftName).font(.caption).foregroundColor(.gray)
                        }
                        if let name = result.registrantNameOrOperator {
                            Text(name).font(.caption2).foregroundColor(.gray)
                        }
                    }
                }
            } // List
                    .navigationTitle("Search")
        } // NavigationView
                .searchable(text: tailnumberBinding, prompt: "Tail number (N123, HB-ABC...)")
    }

    private func onKeyPressed() {
        registrationService.fetchTailnumbersAsync(startingWith: tailnumber) { results in
            autocompleteResults = results
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
