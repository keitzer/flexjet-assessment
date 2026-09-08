import Foundation
import Security

/// Stores the bearer token in the Keychain.
///
/// A token is a credential, so it does not belong in `UserDefaults`. `afterFirstUnlock` lets a
/// background refresh read it without requiring the device to be unlocked at that moment.
nonisolated struct KeychainTokenStorage: TokenStorage {
    private let service: String
    private let account: String

    init(service: String = "com.interview.Flights", account: String = "authToken") {
        self.service = service
        self.account = account
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func load() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data
        else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func save(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        // Delete first so this is an upsert rather than a duplicate-item error.
        SecItemDelete(baseQuery as CFDictionary)
        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(query as CFDictionary, nil)
    }

    func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }
}
