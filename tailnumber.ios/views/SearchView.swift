//
//  ContentView.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 30.03.22.
//

import SwiftUI

struct SearchView: View {
    private let registrationService = RegistrationService()
    @StateObject private var searchText = SearchText()
    @State private var autocompleteResults: [AutocompleteResult] = []
    @State private var model: String = ""
    @State private var isSearching = false
    @State private var navigateOnSubmitEnabled = false
    private let navigationTitle = "Tail Number"

    var body: some View {
        let searchTextBinding = Binding<String>(get: { searchText.value }, set: {
            searchText.value = $0//.uppercased()
            if searchText.value.count > 2 {
                isSearching = true
                fetchSuggestions()
            } else {
                autocompleteResults = []
            }
        })

        NavigationView {

            if searchText.value.isEmpty {
                VStack {
                    Text("Enter a tail number (e.g. N123 or HB-ABC), the owner name or part of the address")
                            .font(.caption)
                    Spacer()
                }
                        .padding()
                        .navigationTitle(navigationTitle)
            } else if !isSearching && searchText.value.count > 2 && autocompleteResults.isEmpty {
                VStack {
                    Text("😔").font(.title)
                    Text("No results.").font(.caption)
                    Spacer()
                }
                        .padding()
                        .navigationTitle(navigationTitle)
            } else {
                ZStack {
                    NavigationLink(destination: RegistrationDetailView(forTailnumber: searchText.value), isActive: $navigateOnSubmitEnabled) {

                    }.hidden()
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
                }
                        .navigationTitle(navigationTitle)
            }
        } // NavigationView
                .searchable(text: searchTextBinding, prompt: "Registration, Owner, Address")
                .disableAutocorrection(true)
                .onSubmit(of: .search) {
                    navigateOnSubmitEnabled = true
                    isSearching = false
                }
                .environmentObject(searchText)
    }

    private func fetchSuggestions() {
        registrationService.autocompleteTailnumberOrRegistrant(tailNumberOrRegistrant: searchText.value) { results in
            autocompleteResults = results
            isSearching = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
