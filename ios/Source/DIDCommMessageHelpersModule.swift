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
        print("[MessageHelpersModule] packEncrypted")
        let msg = parseMessage(msg: messageData)
        
        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)

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
                           to: to as String,
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
        
        let msg = parseMessage(msg: messageData)
        
        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)

        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .packSigned(msg: msg,
                        signBy: signBy as String,
                        cb: delegate)
    }
    
    @objc(packPlaintext: resolversId:withResolver:withRejecter:)
    func packPlaintext(_ messageData: NSDictionary,
                         resolversId: NSString,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - packPlainText")

        let msg = parseMessage(msg: messageData)
        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)
        
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver,
                        secretResolver: secretsResolver)
            .packPlaintext(msg: msg, cb: delegate)
    }
    
    @objc(unpack:resolversId:withResolver:withRejecter:)
    func unpack(_ packedMsg: NSString,
                  resolversId: NSString,
                  resolve: @escaping RCTPromiseResolveBlock,
                  reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - unpack")

        let options = UnpackOptions(expectDecryptByAllKeys: false,
                                   unwrapReWrappingForward: false)

        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)

        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .unpack(msg: packedMsg as String,
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
        
        print("[MessageHelpersModule] - wrapInForward")

        let didResolver = DidResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId: resolversId as String)
        let secretsResolver = SecretsResolverProxy(resolversProxyModule: DIDCommResolversProxyModule(), resolversId:  resolversId as String)

        let encAlgAnon = parseAnonCryptAlg(type: jsAnonCryptAlg)
        
        let delegate = DidWrapPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .wrapInForward(msg: message as String,
                           headers: headers as! [String: String],//[ "oi": "{\"messagespecificattribute\": \"and its value\"}" ],
                           to: to as String,
                           routingKeys: routingKeys as! [String],
                           encAlgAnon: encAlgAnon,
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
        print("[MessageHelpersModule] - DidWrapPromise", result)
        resolve(result)
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[MessageHelpersModule] - Error wrap", msg, err)
        reject(msg, msg, nil)
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
        print("[MessageHelpersModule] - success PackEncryptedMetadata", result, metadata.dataDictionary())
        //TODO: STRINGFY METADATA
        resolve([result, metadata.dataDictionary()])
    }
    
    func success(result: String) {
        print("[MessageHelpersModule] - success plain", result)
        resolve(result)
    }
    
    func success(result: String, metadata: PackSignedMetadata) {
        print("[MessageHelpersModule] - success PackSignedMetadata")
        resolve([result, metadata])
    }
    
    func success(result: Message, metadata: UnpackMetadata) {
        print("[MessageHelpersModule] - success UnpackMetadata")
        resolve([result.dataDictionary(), metadata])
    }
    
    func error(err: ErrorKind, msg: String) {
        print("[MessageHelpersModule] - Error")
        reject(msg, msg, nil)
    }
}

extension Message {
    func dataDictionary() -> [String: Any?] {
        return [ "id": self.id,
                 "typ": self.typ,
                 "type": self.type,
                 "body": self.body,
                 "from": self.from,
                 "to": self.to,
                 "thid": self.thid,
                 "pthid": self.pthid,
                 "extraHeaders": self.extraHeaders,
                 "createdTime": self.createdTime,
                 "expiresTime": self.expiresTime,
                 "fromPrior": self.fromPrior,
                 "attachments": nil ]
    }
}

extension Attachment {
    func dataDictionary() -> [String: Any?] {
        return [ "data": self.data,
                 "id": self.id,
                 "description": self.description,
                 "filename": self.filename,
                 "mediaType": self.mediaType,
                 "format": self.format,
                 "lastmodTime": self.lastmodTime,
                 "byteCount": self.byteCount ]

    }
}

extension PackEncryptedMetadata {
    func dataDictionary() -> [String: Any?] {
        return [ "messagingService": self.messagingService?.dataDictionary(),
                 "fromKid": self.fromKid,
                 "signByKid": self.signByKid,
                 "toKids": self.toKids ]
    }
}

extension MessagingServiceMetadata {
    func dataDictionary() -> [String: Any?] {
        return [ "id": self.id,
                 "serviceEndpoint": self.serviceEndpoint ]
    }
}
