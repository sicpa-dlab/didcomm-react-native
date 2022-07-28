import DidcommSDK
import Foundation

@objc(DIDCommFromPriorHelpersModule)
class DIDCommFromPriorHelpersModule : NSObject {
    
    @objc(pack:issuerKid:resolversId:withResolver:withRejecter:)
    func pack(_ fromPriorData: NSDictionary,
              issuerKid: NSString,
              resolversId: NSString,
              resolve: @escaping RCTPromiseResolveBlock,
              reject: @escaping RCTPromiseRejectBlock) {

        print("[DIDCommFromPriorHelpersModule] - Called pack")
        
        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPriorPromise(resolve, reject)
        
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packFromPrior(msg: .init(fromJson: fromPriorData),
                           issuerKid: issuerKid as String,
                           cb: delegate)
    }
    
    @objc(unpack:resolversId:withResolver:withRejecter:)
    func unpack(_ fromPriorJwt: NSString,
                resolversId: NSString,
                resolve: @escaping RCTPromiseResolveBlock,
                reject: @escaping RCTPromiseRejectBlock) {
        
        print("[DIDCommFromPriorHelpersModule] - Called unpack")
        
        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPriorPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver,
                        secretResolver: secretsResolver)
            .unpackFromPrior(fromPriorJwt: fromPriorJwt.asString,
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
        reject(msg, err.localizedDescription, err)
    }
}

