public class SecretsResolverProxy: SecretsResolver {
    
    let resolversProxyModule: DIDCommResolversProxyModule
    let resolversId: String
    
    init(resolversProxyModule: DIDCommResolversProxyModule, resolversId: String) {
        self.resolversProxyModule = resolversProxyModule
        self.resolversId = resolversId
    }
    
    
    public func getSecret(secretid: String, cb: OnGetSecretResult) -> ErrorCode {
        print("[SecretsResolverProxy] getSecret")
        resolveKidFromProxy(kid: secretid) { secret in
            
//            do {
                try? cb.success(result: secret)
//            } catch {
//                print("getSecret error")
//            }
        }
        return .success
    }
    
    public func findSecrets(secretids: [String], cb: OnFindSecretsResult) -> ErrorCode {
        print("[SecretsResolverProxy] findSecrets")
        resolveKidsFromProxy(kids: secretids) { secrets in
 //           do {
                try? cb.success(result: secrets)
//            } catch {
//                do {
//                    print("Called error")
//                    try cb.error(err: .DidNotResolved(message: "x"), msg: "y")
//                } catch {
//                    print("findSecrets error")
//                }
//            }
        }
        //ignore
        return .success
    }
    
    private func resolveKidFromProxy(kid: String,  completion: @escaping (_ secret: Secret?) -> ()) {
        print("[SecretsResolverProxy] resolveKidFromProxy")
        
        print("--------resp", self.resolversId)
        resolversProxyModule.sendEvent(event: .FindKey(kid: kid), resolversId: self.resolversId)
        //use did of user as key
        //add resolvers id
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(self.resolversId+"kid"),
                object: nil,
                queue: nil) { notification in
                    print("[SecretsResolverProxy] completion", notification.object)
                    if let str = notification.object as? String {
                        let json = convertToDictionary(text: str)
                        //no force unwrap
                        let secret = parseSecret(json: json!)
                        completion(secret)
                    }
                }
    }
    
    private func resolveKidsFromProxy(kids: [String],  completion: @escaping (_ secrets: [String]) -> ()) {
        print("[SecretsResolverProxy] resolveKidsFromProxy")
        resolversProxyModule.sendEvent(event: .FindKeys(kids: kids), resolversId: resolversId)
        //use did of user as key
        //add resolvers id
        NotificationCenter
            .default
            .addObserver(
                forName: NSNotification.Name(resolversId+"kids"),
                object: nil,
                queue: nil) { notification in
                    print("[SecretsResolverProxy] completion")
                    if let str = notification.object as? String {
                        if let array = convertToArray(text: str) {
                            completion(array)
                        }
                    }

                }
    }
    
}
