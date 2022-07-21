
public class DidResolverProxy: DidResolver {
    
    let resolversProxyModule: DIDCommResolversProxyModule
    let resolversId: String
    
    init(resolversProxyModule: DIDCommResolversProxyModule, resolversId: String) {
        self.resolversProxyModule = resolversProxyModule
        self.resolversId = resolversId
    }
    
    public func resolve(did: String, cb: OnDidResolverResult) -> ErrorCode {
        print("[DidResolverProxy] resolve", did)
        resolveDidFromProxy(did: did) { didDoc in
            // is it really necessary?
            print("[DidResolverProxy] completion resolveDidFromProxy", didDoc?.did)
//            if (didDoc?.did != did) {
//                //how to get an error?
//                try? cb.error(err: .DidNotResolved(message: ""), msg: "msg")
//            } else {
                try? cb.success(result: didDoc)
//            }
        }
        return .success
    }
    
    private func resolveDidFromProxy(did: String,  completion: @escaping (_ didDoc: DidDoc?) -> ()) {
        print("[DidResolverProxy] resolveDidFromProxy")
        resolversProxyModule.sendEvent(event: .ResolveDid(did: did), resolversId: resolversId)
        //use did of user as key
        //add resolvers id
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name("did"),
                object: nil,
                queue: nil) { notification in
                    print("[DidResolverProxy] completion")
                    
                    if let str = notification.object as? String {
                        let json = convertToDictionary(text: str)
                        let didDoc = parseDidDoc(json: json!)
                        completion(didDoc)
                    }
                }
    }
}

