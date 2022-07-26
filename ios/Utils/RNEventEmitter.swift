@objc(RNEventEmitter)
open class RNEventEmitter: RCTEventEmitter {
    private static var emitter: RCTEventEmitter!
    
    private var hasListeners: Bool
    
    private static let DID_STRING_KEY = "did"
    private static let KID_STRING_KEY = "kid"
    private static let KIDS_STRING_KEY = "kids"
    private static let RESOLVERS_ID_STRING_KEY = "resolversId"
    
    override init() {
        hasListeners = false
        super.init()
        RNEventEmitter.emitter = self
    }

    open override func supportedEvents() -> [String] {
        ["resolve-did", "find-key", "find-keys"]
    }

    open override func startObserving() {
        hasListeners = true
    }

    open override func stopObserving() {
        hasListeners = false
    }
    
    static func sendEvent(event: ResolverProxyEvent, resolversId: String) {
        var params: JSONDictionary = [RESOLVERS_ID_STRING_KEY: resolversId]

        switch event {
        case .ResolveDid(let did):
            params.updateValue(did, forKey: DID_STRING_KEY)
        case .FindKey(let kid):
            params.updateValue(kid, forKey: KID_STRING_KEY)
        case .FindKeys(let kids):
            params.updateValue(kids, forKey: KIDS_STRING_KEY)
        }
        
        emitter.sendEvent(withName: event.key, body: params)
    }
}
