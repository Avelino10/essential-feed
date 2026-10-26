//
//  SharedLocalizationTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/12/2021.
//

@testable import EssentialFeed
import Foundation
import Testing

func localized(_ key: String, table: String) -> String {
    let value = Bundle.essentialFeed.localizedString(forKey: key, value: nil, table: table)

    if value == key {
        Issue.record("Missing localized string for key: \(key) in table: \(table)")
    }

    return value
}

func expectLocalizedKeysAndValuesExist(in presentationBundle: Bundle, _ table: String) {
    let localizationBundles = allLocalizationBundles(in: presentationBundle)
    let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)

    for (bundle, localization) in localizationBundles {
        for key in localizedStringKeys {
            let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
            let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)

            if localizedString == key {
                Issue.record("Missing \(language) (\(localization)) localized string for key: '\(key)' in table: '\(table)'")
            }
        }
    }
}

private typealias LocalizedBundles = (bundle: Bundle, localization: String)

private func allLocalizationBundles(in bundle: Bundle) -> [LocalizedBundles] {
    return bundle.localizations.compactMap { localization in
        guard let path = bundle.path(forResource: localization, ofType: "lproj"), let localizedBundle = Bundle(path: path) else {
            Issue.record("Couldn't find bundle for localization: \(localization)")
            return nil
        }

        return (localizedBundle, localization)
    }
}

private func allLocalizedStringKeys(in bundles: [LocalizedBundles], table: String) -> Set<String> {
    return bundles.reduce([]) { acc, current in
        guard let path = current.bundle.path(forResource: table, ofType: "strings"),
              let strings = NSDictionary(contentsOfFile: path),
              let keys = strings.allKeys as? [String]
        else {
            Issue.record("Couldn't load localized strings for localization: \(current.localization)")
            return acc
        }

        return acc.union(Set(keys))
    }
}
