import Foundation
import KeyboardKit

extension KKL10n {
  func hamsterText(for context: KeyboardContext) -> String {
    hamsterText(for: context.locale)
  }

  func hamsterText(for locale: KeyboardLocale) -> String {
    hamsterText(for: locale.locale)
  }

  func hamsterText(for locale: Locale) -> String {
    Self.hamsterText(forKey: key, locale: locale)
  }

  static func hamsterText(forKey key: String, locale: KeyboardLocale) -> String {
    hamsterText(forKey: key, locale: locale.locale)
  }

  static func hamsterText(forKey key: String, locale: Locale) -> String {
    guard let bundle = Bundle.main.bundle(for: locale) else {
      return ""
    }
    return NSLocalizedString(key, bundle: bundle, comment: "")
  }
}

extension Bundle {
  func bundle(for locale: Locale) -> Bundle? {
    guard let bundlePath = bundlePath(for: locale) else { return nil }
    return Bundle(path: bundlePath)
  }

  func bundlePath(for locale: Locale) -> String? {
    return bundlePath(named: locale.identifier) ?? bundlePath(named: locale.languageCode)
  }

  func bundlePath(named name: String?) -> String? {
    path(forResource: name ?? "", ofType: "lproj")
  }
}
