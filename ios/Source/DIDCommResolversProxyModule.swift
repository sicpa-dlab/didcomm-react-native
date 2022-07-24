import Foundation

@objc(DIDCommResolversProxyModule)
class DIDCommResolversProxyModule: NSObject {
    
    private let DID_STRING_KEY = "did"
    private let KID_STRING_KEY = "kid"
    private let KIDS_STRING_KEY = "kids"
    private let RESOLVERS_ID_STRING_KEY = "resolversId"
    
    @objc(setResolvedDid:resolversId:)
    func setResolvedDid(_ jsonValue: NSString?, resolversId: String) {
        //use did of user as key
        print("[setResolvedDid]:", jsonValue ?? "No value", resolversId)
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"did"), object: jsonValue)
    }
    @objc(setFoundSecret:resolversId:)
    func setFoundSecret(_ jsonValue: NSString?, resolversId: String) {
        print("[setFoundSecret]:", jsonValue ?? "No value",resolversId)
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kid"), object: jsonValue)
    }

    @objc(setFoundSecretIds:resolversId:)
    func setFoundSecretIds(_ jsonValue: NSString?, resolversId: String) {
        print("[setFoundSecretIds]:", jsonValue ?? "No value", resolversId)
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kids"), object: jsonValue)
    }
    
    public func sendEvent(event: ResolverProxyEvent, resolversId: String) {
        print("[sendEvent]: sendEvent", resolversId)
        
        var params: [String:Any?] = [RESOLVERS_ID_STRING_KEY:resolversId]

        switch event {
        case .ResolveDid(let did):
            params.updateValue(did, forKey: DID_STRING_KEY)
        case .FindKey(let kid):
            params.updateValue(kid, forKey: KID_STRING_KEY)
        case .FindKeys(let kids):
            params.updateValue(kids, forKey: KIDS_STRING_KEY)
        }
        
        RNEventEmitter.emitter.sendEvent(withName: event.key, body: params)
    }
}
