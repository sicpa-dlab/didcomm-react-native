extension SecretMaterial {
    static func fromString(_ format: String, jsonString: String) -> SecretMaterial{
        switch format.lowercased() {
        case "jwk":
            return .jwk(value: jsonString)
        case "multibase":
            return .multibase(value: jsonString)
        case "base58":
            return .base58(value: jsonString)
        case "hex":
            return .hex(value: jsonString)
        default:
            return .other(value: jsonString)
        }
    }
}

