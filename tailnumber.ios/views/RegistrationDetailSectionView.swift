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
//            Text(label)
//                    .font(.title)
//                    .padding([.bottom], 5)

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
                                Text(value)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.trailing)
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
