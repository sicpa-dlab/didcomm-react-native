
public func createResolvers(with resolversId: NSString) -> (DidResolverProxy, SecretsResolverProxy) {
    let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId.asString)
    let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId.asString)
    return (didResolver, secretsResolver)
}
