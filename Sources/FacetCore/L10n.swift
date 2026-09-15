import Foundation

/// Shared by iPhone and Watch. Localization is resolved on the displaying device;
/// cached contact labels are rebuilt on iPhone; Watch receives only QR patterns.
public enum L10n {
    public static func text(_ key: String) -> String {
        Bundle.module.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    public static func fieldLabel(_ field: String, _ label: String) -> String {
        String(format: text("field.labeled"), locale: Locale.current, field, label)
    }

    // Internal access lets tests verify packaged translations without changing user preferences.
    static var resourceBundle: Bundle { .module }
}
