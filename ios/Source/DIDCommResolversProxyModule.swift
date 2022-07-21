import Foundation

@objc(DIDCommResolversProxyModule)
class DIDCommResolversProxyModule: NSObject {
    
    private let DID_STRING_KEY = "did"
    private let KID_STRING_KEY = "kid"
    private let KIDS_STRING_KEY = "kids"
    private let RESOLVERS_ID_STRING_KEY = "resolversId"

    @objc(setResolvedDid:)
    func setResolvedDid(_ jsonValue: NSString?) {
        print("[setResolvedDid]:", jsonValue)
//        print(jsonValue, convertToDictionary(text: jsonValue! as String))
        //Needs to parse!!!!
        //use did of user as key
        
        NotificationCenter.default.post(name: NSNotification.Name("did"), object: jsonValue)
    }
    @objc(setFoundSecret:)
    func setFoundSecret(_ jsonValue: NSString?) {
        print("[setFoundSecret]:", jsonValue ?? "No value")
    }

    @objc(setFoundSecretIds:)
    func setFoundSecretIds(_ jsonValue: NSString?) {
        print("[setFoundSecretIds]:", jsonValue ?? "No value")
    }
    
    public func sendEvent(event: ResolverProxyEvent, resolversId: String) {
        print("[sendEvent]: sendEvent")
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
