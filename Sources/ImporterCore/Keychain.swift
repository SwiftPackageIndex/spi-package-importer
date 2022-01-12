import Foundation

public enum Keychain {
    // via https://www.advancedswift.com/secure-private-data-keychain-swift/
    public enum KeychainError: Error {
        case itemNotFound
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
    }

    public static func readData(service: String, account: String) throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,

            // kSecMatchLimitOne indicates keychain should read
            // only the most recent item matching this query
            kSecMatchLimit as String: kSecMatchLimitOne,

            // kSecReturnData is set to kCFBooleanTrue in order
            // to retrieve the data for the item
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        switch status {
            case errSecSuccess:
                break // ok
            case errSecItemNotFound:
                throw KeychainError.itemNotFound
            default:
                throw KeychainError.unexpectedStatus(status)
        }

        guard let password = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }

        return password
    }

    public static func readString(service: String, account: String) throws -> String {
        try String(decoding: readData(service: service, account: account), as: UTF8.self)
    }
}
