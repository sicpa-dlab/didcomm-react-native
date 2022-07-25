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
        
        print("[MessageHelpersModule] - Called packEncrypted")

        // This is the standard options for Encrypting.
        let options = PackEncryptedOptions(protectSender: false,
                                           forward: false,
                                           forwardHeaders: [:],
                                           messagingService: nil,
                                           encAlgAuth: .a256cbcHs512Ecdh1puA256kw,
                                           encAlgAnon: .xc20pEcdhEsA256kw)
        
        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packEncrypted(msg: .init(fromJson: messageData),
                           to: to.asString,
                           from: from?.asString,
                           signBy: signFrom?.asString,
                           options: options,
                           cb: delegate)
    }
    
    @objc(packSigned: signBy: resolversId:withResolver:withRejecter:)
    func packSigned(_ messageData: NSDictionary,
                      signBy: NSString,
                      resolversId: NSString,
                      resolve: @escaping RCTPromiseResolveBlock,
                      reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called packSigned")
        
        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packSigned(msg: .init(fromJson: messageData),
                        signBy: signBy.asString,
                        cb: delegate)
    }
    
    @objc(packPlaintext: resolversId:withResolver:withRejecter:)
    func packPlaintext(_ messageData: NSDictionary,
                         resolversId: NSString,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called packPlaintext")

        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver,
                        secretResolver: secretsResolver)
            .packPlaintext(msg: .init(fromJson: messageData),
                           cb: delegate)
    }
    
    @objc(unpack:resolversId:withResolver:withRejecter:)
    func unpack(_ packedMsg: NSString,
                  resolversId: NSString,
                  resolve: @escaping RCTPromiseResolveBlock,
                  reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called unpack")

        let options = UnpackOptions(expectDecryptByAllKeys: false,
                                   unwrapReWrappingForward: false)

        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .unpack(msg: packedMsg.asString,
                    options: options,
                    cb: delegate)
    }
    
    @objc(wrapInForward:headers:to:routingKeys:jsAnonCryptAlg:resolversId:withResolver:withRejecter:)
    func wrapInForward(_ message: NSString,
                       headers: NSDictionary,
                       to: NSString,
                       routingKeys: NSArray,
                       jsAnonCryptAlg: NSString,
                       resolversId: NSString,
                       resolve: @escaping RCTPromiseResolveBlock,
                       reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called wrapInForward")

        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        
        let delegate = DidWrapPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .wrapInForward(msg: message.asString,
                           headers: headers as? [String: String] ?? [:],
                           to: to.asString,
                           routingKeys: routingKeys as? [String] ?? [],
                           encAlgAnon: .fromString(jsAnonCryptAlg.asString),
                           cb: delegate)
    }
}

fileprivate class DidWrapPromise: OnWrapInForwardResult {
    let resolve: RCTPromiseResolveBlock
    let reject: RCTPromiseRejectBlock
    init(_ resolve: @escaping RCTPromiseResolveBlock,
         _ reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject
    }
    
    func success(result: String) {
        print("[MessageHelpersModule] - Success OnWrapInForwardResult")
        resolve(result)
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[MessageHelpersModule] - Error OnWrapInForwardResult")
        reject(msg, err.localizedDescription, nil)
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
        print("[MessageHelpersModule] - Success OnPackEncryptedResult")
        resolve([result, metadata.dataDictionary()])
    }
    
    func success(result: String) {
        print("[MessageHelpersModule] - Success OnPackPlaintextResult")
        resolve(result)
    }
    
    func success(result: String, metadata: PackSignedMetadata) {
        print("[MessageHelpersModule] - Success OnPackSignedResult")
        resolve([result, metadata.dataDictionary()])
    }
    
    func success(result: Message, metadata: UnpackMetadata) {
        print("[MessageHelpersModule] - Success OnUnpackResult")
        resolve([result.dataDictionary(), metadata.dataDictionary()])
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[MessageHelpersModule] - Genric Error")
        reject(msg, err.localizedDescription, nil)
    }
}

