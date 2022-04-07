//
// Created by Mathieu Clement on 07.04.22.
//

import Foundation

class LocalizationManager {
    private var loadingTexts = [
        "Priming the engine",
        "Fetching data",
        "Spooling up the engines",
        "Tuning in ground frequency",
        "Turning on magnetos",
        "\"Aviate, Navigate, Communicate\"",
        "A good pilot is always learning"
    ]

    func randomLoadingText() -> String {
        loadingTexts[Int.random(in: 0..<loadingTexts.count)]
    }
}
