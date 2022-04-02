//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation

protocol HasApply { }

extension HasApply {
    func apply(closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}

extension String {
    func containsDigits() -> Bool {
        self.contains { c in
            c.isNumber
        }
    }

    func containsLowercase() -> Bool {
        self.contains { c in
            c.isLowercase
        }
    }

    var smartCapitalized: String {
        var words : [String] = []
        self.components(separatedBy: " ").forEach { word in
            if (word == "de" || word == "du") {
                words.append(word.lowercased())
            } else if (word == "BOX" || word == "INC" || word == "RD" || word == "ST" || word == "WY" || word == "LN"
                    || word == "CO" || word == "STE" || word == "APT" || word == "DR" || word == "CIR" || word == "HWY"
                    || word.count > 3) {
                words.append(word.lowercased().capitalized)
            } else {
                words.append(word)
            }
        }
        return words.joined(separator: " ")
    }

    var fromJavaEnum: String {
        self.replacingOccurrences(of: "_", with: " ").smartCapitalized
    }
}

extension Int {
    var stringValue: String {
        "\(self)"
    }
}

extension DateFormatter : HasApply { }

private var usDateFormatter = DateFormatter().apply { formatter in
    formatter.dateFormat = "MM/dd/yyyy"
    formatter.locale = Locale(identifier: "en_US")
}

extension Date {
    var usFormat: String {
        usDateFormatter.string(from: self)
    }
}

extension NumberFormatter : HasApply { }
private let numberFormatter = NumberFormatter().apply { formatter in
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
}
extension Formatter {
    static let withSeparator: NumberFormatter = {
        numberFormatter
    }()
}
extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}
