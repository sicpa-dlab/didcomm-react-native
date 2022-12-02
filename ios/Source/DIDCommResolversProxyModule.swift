import DidcommSDK
import Foundation

@objc(DIDCommResolversProxyModule)
class DIDCommResolversProxyModule: RCTEventEmitter {
    
    private static var emitter: RCTEventEmitter!
    
    private static let DID_STRING_KEY = "did"
    private static let KID_STRING_KEY = "kid"
    private static let KIDS_STRING_KEY = "kids"
    private static let RESOLVERS_ID_STRING_KEY = "resolversId"
    
    override init() {
        super.init()
        DIDCommResolversProxyModule.emitter = self
    }
    
    @objc(setResolvedDid:resolversId:)
    func setResolvedDid(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"did"), object: jsonValue)
    }
    @objc(setFoundSecret:resolversId:)
    func setFoundSecret(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kid"), object: jsonValue)
    }

    @objc(setFoundSecretIds:resolversId:)
    func setFoundSecretIds(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kids"), object: jsonValue)
    }

    open override func supportedEvents() -> [String] {
        ["resolve-did", "find-key", "find-keys"]
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
