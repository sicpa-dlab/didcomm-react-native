import DidcommSDK


enum DecodeError: Error {
    case error(_ msg: String)
}

public func createResolvers(with resolversId: NSString) -> (DidResolverProxy, SecretsResolverProxy) {
    let didResolver = DidResolverProxy(resolversId: resolversId.asString)
    let secretsResolver = SecretsResolverProxy(resolversId:  resolversId.asString)
    return (didResolver, secretsResolver)
}
