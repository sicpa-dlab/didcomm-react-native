public class SecretsResolverProxy: SecretsResolver {
    
    let resolversId: String
    
    init(resolversId: String) {
        self.resolversId = resolversId
    }
    
    public func getSecret(secretid: String, cb: OnGetSecretResult) -> ErrorCode {
        resolveKidFromProxy(kid: secretid) { secret in
            //TODO: understand how to properly call the callback
            try? cb.success(result: secret)
        }
        return .success
    }
    
    public func findSecrets(secretids: [String], cb: OnFindSecretsResult) -> ErrorCode {
        resolveKidsFromProxy(kids: secretids) { secrets in
            //TODO: understand how to properly call the callback
            try? cb.success(result: secrets)
        }
        return .success
    }
    
    private func resolveKidFromProxy(kid: String,  completion: @escaping (_ secret: Secret?) -> ()) {
        DIDCommResolversProxyModule.sendEvent(event: .FindKey(kid: kid), resolversId: self.resolversId)
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(self.resolversId+"kid"),
                object: nil,
                queue: nil) { notification in
                    if let str = notification.object as? String,
                       let dic = str.asDictionary {
                        completion(Secret.init(fromJson: dic))
                    } else {
                        completion(nil)
                    }
                }
    }
    
    private func resolveKidsFromProxy(kids: [String],  completion: @escaping (_ secrets: [String]) -> ()) {
        DIDCommResolversProxyModule.sendEvent(event: .FindKeys(kids: kids), resolversId: resolversId)
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(resolversId+"kids"),
                object: nil,
                queue: nil) { notification in
                    if let str = notification.object as? String {
                        if let array = str.asArray {
                            completion(array)
                        }
                    }
                }
    }
}
