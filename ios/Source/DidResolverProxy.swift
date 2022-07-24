
public class DidResolverProxy: DidResolver {
    
    let resolversProxyModule: DIDCommResolversProxyModule
    let resolversId: String
    
    init(resolversProxyModule: DIDCommResolversProxyModule, resolversId: String) {
        self.resolversProxyModule = resolversProxyModule
        self.resolversId = resolversId
    }
    
    //pay attention here
    public func resolve(did: String, cb: OnDidResolverResult) -> ErrorCode {
        print("[DidResolverProxy] resolve", did)
        resolveDidFromProxy(did: did) { didDoc in
            // is it really necessary?
            print("[DidResolverProxy] completion resolveDidFromProxy")
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
        print("--------resp", self.resolversId)

        resolversProxyModule.sendEvent(event: .ResolveDid(did: did), resolversId: self.resolversId)
        //use did of user as key
        //add resolvers id
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(self.resolversId+"did"),
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

extension FromPrior {
    
}
