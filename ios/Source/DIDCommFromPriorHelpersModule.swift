import Foundation

@objc(DIDCommFromPriorHelpersModule)
class DIDCommFromPriorHelpersModule : NSObject {
    
    @objc(pack:issuerKid:resolversId:withResolver:withRejecter:)
    func pack(_ fromPriorData: NSDictionary,
              issuerKid: NSString,
              resolversId: NSString,
              resolve: @escaping RCTPromiseResolveBlock,
              reject: @escaping RCTPromiseRejectBlock) {
        
        let fromPrior = unpackFromPrior(fromPriorData)

        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(),
                                           resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(),
                                                   resolversId:  resolversId as String)

        let delegate = DidPriorPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packFromPrior(msg: fromPrior, issuerKid: issuerKid as String, cb: delegate)
    }
    
    @objc(unpack:resolversId:withResolver:withRejecter:)
    func unpack(_ fromPriorJwt: NSString,
                resolversId: NSString,
                resolve: @escaping RCTPromiseResolveBlock,
                reject: @escaping RCTPromiseRejectBlock) {
        

        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)
        
        let delegate = DidPriorPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver,
                        secretResolver: secretsResolver)
            .unpackFromPrior(fromPriorJwt: fromPriorJwt as String,
                             cb: delegate)
    }
}

fileprivate class DidPriorPromise: OnFromPriorPackResult, OnFromPriorUnpackResult {
    let resolve: RCTPromiseResolveBlock
    let reject: RCTPromiseRejectBlock
    init(_ resolve: @escaping RCTPromiseResolveBlock,
         _ reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject
    }
    
    func success(frompriorjwt: String, kid: String) {
        print("[OnFromPriorPackResult] - Success")
        resolve([frompriorjwt, kid])
    }
    
    func success(fromprior: FromPrior, kid: String) {
        print("[OnFromPriorUnpackResult] - Success")
        resolve([fromprior.dataDictionary(), kid])
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[OnFromPriorPackResult, OnFromPriorUnpackResult] - Error")
    }
}

extension FromPrior {
    func dataDictionary() -> [String: Any?] {
        return [ "iss": iss,
                 "sub": sub,
                 "aud": aud,
                 "exp": exp,
                 "nbf": nbf,
                 "iat": iat,
                 "jti": jti ]
    }
}
