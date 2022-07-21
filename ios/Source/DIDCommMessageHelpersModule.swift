import Foundation

@objc(DIDCommMessageHelpersModule)
class DIDCommMessageHelpersModule: NSObject {
    
    @objc(packEncrypted:to:from:signFrom:protectSender:resolversId:withResolver:withRejecter:)
    func packEncrypted(_ messageData: NSDictionary,
                        to: NSString,
                        from: NSString? = nil,
                        signFrom: NSString? = nil,
                        protectSender: Bool = true,
                        resolversId: NSString,
                        resolve: @escaping RCTPromiseResolveBlock,
                        reject: @escaping RCTPromiseRejectBlock) {
        print("[MessageHelpersModule] packEncrypted", to, from, messageData)
        let msg = parseMessage(msg: messageData)
        
//        let didResolver = ExampleDidResolver(knownDids: [])
//        let secretsResolver = ExampleSecretsResolver(knownSecrets: [])
        
        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(),
                                           resolversId: resolversId as String)
        let secretsResolver = ExampleSecretsResolver(knownSecrets: [])

        /**
         This is the standard options for Encrypting.
         */
        let options = PackEncryptedOptions(protectSender: false,
                                           forward: false,
                                           forwardHeaders: [:],
                                           messagingService: nil,
                                           encAlgAuth: .a256cbcHs512Ecdh1puA256kw,
                                           encAlgAnon: .xc20pEcdhEsA256kw)

        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packEncrypted(msg: msg,
                           to: String(to),
                           from: from as? String,
                           signBy: signFrom as? String,
                           options: options,
                           cb: delegate)
    }
    
    @objc(packSigned: signBy: resolversId:withResolver:withRejecter:)
    func packSigned(_ messageData: NSDictionary,
                      signBy: NSString,
                      resolversId: NSString,
                      resolve: @escaping RCTPromiseResolveBlock,
                      reject: @escaping RCTPromiseRejectBlock) {
        
//        let msg = parseMessage(msg: messageData)
//        let didResolver = ExampleDidResolver(knownDids: [])
//        let secretsResolver = ExampleSecretsResolver(knownSecrets: [])
//
//        let delegate = DidPromise(resolve, reject)
//        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
//            .packSigned(msg: msg, signBy: signBy as String, cb: delegate)
    }
    
    @objc(packPlainText: signBy: resolversId: resolve: reject:)
    func packPlainText(_ messageData: NSDictionary,
                         signBy: NSString,
                         resolversId: NSString,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - packPlainText")
        
//        let msg = parseMessage(msg: messageData)
//        let didResolver = ExampleDidResolver(knownDids: [])
//        let secretsResolver = ExampleSecretsResolver(knownSecrets: [])
//
//        let delegate = DidPromise(resolve, reject)
//        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
//            .packPlaintext(msg: msg, cb: delegate)
    }
    
    @objc(unpack:resolversId:expectDecryptByAllKeys:unwrapReWrappingForward:withResolver:withRejecter:)
    func unpack(_ packedMsg: NSString,
                  resolversId: NSString,
                  expectDecryptByAllKeys: Bool = false,
                  unwrapReWrappingForward: Bool = false,
                  resolve: @escaping RCTPromiseResolveBlock,
                  reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - unpack")
        
        let _ = UnpackOptions(expectDecryptByAllKeys: expectDecryptByAllKeys,
                                   unwrapReWrappingForward: unwrapReWrappingForward)
        
//        let didComm = createDidCommInstance(resolversId: resolversId)
    }
    
    private func createDidCommInstance(resolversId: NSString) -> DidComm {
        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy()
        return DidComm(didResolver: didResolver, secretResolver: secretsResolver)
    }
}

fileprivate class DidPromise: OnPackEncryptedResult, OnPackPlaintextResult, OnPackSignedResult, OnUnpackResult {
    let resolve: RCTPromiseResolveBlock
    let reject: RCTPromiseRejectBlock
    init(_ resolve: @escaping RCTPromiseResolveBlock,
         _ reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject
    }
    
    func success(result: String, metadata: PackEncryptedMetadata) {
        print("[MessageHelpersModule] - success PackEncryptedMetadata")
        resolve(result)
    }
    
    func success(result: String) {
        print("[MessageHelpersModule] - success")
        resolve(result)
    }
    
    func success(result: String, metadata: PackSignedMetadata) {
        print("[MessageHelpersModule] - success PackSignedMetadata")
        resolve(result)
    }
    
    func success(result: Message, metadata: UnpackMetadata) {
        print("[MessageHelpersModule] - success UnpackMetadata")
        resolve(result)
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[MessageHelpersModule] - Error", msg, err)
        reject(msg, msg, nil)
    }
}
