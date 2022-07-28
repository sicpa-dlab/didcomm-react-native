import DidcommSDK
import Foundation

enum ResolverProxyEvent {
    case ResolveDid(did: String)
    case FindKey(kid: String)
    case FindKeys(kids: [String])
    
    var key: String {
        switch self {
        case .ResolveDid:
            return "resolve-did"
        case .FindKey:
            return "find-key"
        case .FindKeys:
            return "find-keys"
        }
    }
}
