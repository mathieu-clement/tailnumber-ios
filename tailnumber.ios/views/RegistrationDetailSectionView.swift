//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation
import SwiftUI

struct RegistrationDetailSectionView: View {

    let label: String
    let rows: [RegistrationDetailRow]

    var body: some View {
        if !rows.isEmpty && rows.contains(where: { row in row.value != nil }) {
            VStack(alignment: .leading) {
                ForEach(0..<rows.count, id: \.self) { i in
                    if i < rows.count {
                        let row = rows[i]
                        if let value = row.value {
                            HStack(alignment: .top) {
                                Text(row.label)
                                        .font(.subheadline)
                                        .bold()
                                Spacer()
                                ValueTextView(value: value, emphasize: row.emphasized)
                            }
                                    .onTapGesture {
                                        row.onTapGesture()
                                    }
                            if (i != rows.count - 1) {
                                Divider()
                            }
                        }
                    }
                }
            }
                    .padding([.bottom], 20)
        }
    }
}

struct ValueTextView: View {

    let value: String
    let emphasize: Bool

    var body: some View {
        if emphasize {
            Text(value)
                    .font(.subheadline)
                    .bold()
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.red)
        } else {
            Text(value)
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
        }
    }
}
