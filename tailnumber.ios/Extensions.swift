//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation

protocol HasApply {
}

extension HasApply {
    func apply(closure: (Self) -> ()) -> Self {
        closure(self)
        return self
    }
}

extension NSRegularExpression {
    func matches(_ word: String) -> Bool {
        firstMatch(in: word, options: [], range: NSRange(location: 0, length: word.utf16.count)) != nil
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

    // TODO this should be on the server side
    var smartCapitalized: String {
        if containsLowercase() {
            return self
        }

        let numberedStreetRegex = try! NSRegularExpression(pattern: "[0-9]+(ST|TH|RD)")

        var words: [String] = []
        self.components(separatedBy: " ").forEach { word in
            if (word == "DE" || word == "DU" || numberedStreetRegex.matches(word)) {
                words.append(word.lowercased())
            } else if (word == "BOX" || word == "INC" || word == "RD" || word == "ST" || word == "WY" || word == "LN"
                    || word == "CO" || word == "STE" || word == "APT" || word == "DR" || word == "CIR" || word == "HWY"
                    || word == "MT" || word == "CT" || word == "PL"
                    || (word.count > 2 && word != "LLC" && word != "II" && word != "III")) {
                words.append(word.lowercased().capitalized)
            } else {
                words.append(word)
            }
        }
        return words.joined(separator: " ")
    }

    var fromJavaEnum: String {
        // Capitalize first word only
        var words = self.components(separatedBy: "_").map { s in
            s.lowercased()
        }

        switch (words[0]) {
            case "llc":
                words[0] = "LLC"
            default:
                words[0] = words[0].capitalized
        }

        return words.joined(separator: " ")
    }
}

extension Int {
    var stringValue: String {
        "\(self)"
    }
}

extension DateFormatter: HasApply {
}

private var userLocaleDateFormatter = DateFormatter().apply { formatter in
    formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
}

extension Date {
    var userLocaleFormat: String {
        userLocaleDateFormatter.string(from: self)
    }
}

extension NumberFormatter: HasApply {
}

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
    var formattedWithSeparator: String {
        Formatter.withSeparator.string(for: self) ?? ""
    }
}
