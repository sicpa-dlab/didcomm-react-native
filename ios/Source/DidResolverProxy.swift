public class DidResolverProxy: DidResolver {
    
    let resolversProxyModule: DIDCommResolversProxyModule
    let resolversId: String
    
    init(resolversProxyModule: DIDCommResolversProxyModule, resolversId: String) {
        self.resolversProxyModule = resolversProxyModule
        self.resolversId = resolversId
    }
    
    public func resolve(did: String, cb: OnDidResolverResult) -> ErrorCode {
        resolveDidFromProxy(did: did) { didDoc in
            //TODO: understand how to properly call the callback
            try? cb.success(result: didDoc)
        }
        return .success
    }
    
    private func resolveDidFromProxy(did: String,  completion: @escaping (_ didDoc: DidDoc?) -> ()) {
        resolversProxyModule.sendEvent(event: .ResolveDid(did: did), resolversId: self.resolversId)
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(self.resolversId+"did"),
                object: nil,
                queue: nil) { notification in
                    if let str = notification.object as? String,
                       let dic = str.asDictionary {
                        completion(.init(fromJson: dic))
                    } else {
                        completion(nil)
                    }
                }
    }
}
