//
//  ContentView.swift
//  tailnumber.ios
//
//  Created by Mathieu Clement on 30.03.22.
//

import SwiftUI

struct ContentView: View {
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

            VStack {
                VStack(alignment: .leading) {
//                Spacer()
                    Text("Search by tail number / aircraft registration").font(.headline)
                    TextField("Tail number", text: tailnumberBinding)//.onSubmit(fetchRegistration)
                }
                        .padding()

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
                                .contentShape(Rectangle())
                    }
//                            .onTapGesture {
//                                tailnumber = result.registrationId.id
//                                detailView.fetchRegistration()
////                                onNavigateToRegistrationScreen()
//                            }
                }

//                Spacer()
            }
                    .padding()
                    .navigationTitle("Search")
        }
    }

    private func onKeyPressed() {
        registrationService.fetchTailnumbersAsync(startingWith: tailnumber) { results in
            autocompleteResults = results
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
