import DidcommSDK
import Foundation

@objc(DIDCommMessageHelpersModule)
class DIDCommMessageHelpersModule: NSObject {
    
    @objc(packEncrypted:to:from:signFrom:optionsJson:resolversId:withResolver:withRejecter:)
    func packEncrypted(_ messageData: NSDictionary,
                        to: NSString,
                        from: NSString? = nil,
                        signFrom: NSString? = nil,
                        optionsJson: NSString? = nil,
                        resolversId: NSString,
                        resolve: @escaping RCTPromiseResolveBlock,
                        reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called packEncrypted")
        
        do {
            let message = try Message(fromJson: messageData)
            
            let (didResolver, secretsResolver) = createResolvers(with: resolversId)
            let delegate = DidPromise(resolve, reject)
            
            let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
                .packEncrypted(msg: message,
                               to: to.asString,
                               from: from?.asString,
                               signBy: signFrom?.asString,
                               options: .init(fromJson: optionsJson),
                               cb: delegate)
        } catch DecodeError.error(let msg) {
            reject("Decode derror:", msg, DecodeError.error(msg))
            return
        } catch {
            reject("Unknown error.", error.localizedDescription, error)
            return
        }
    }
    
    @objc(packSigned: signBy: resolversId:withResolver:withRejecter:)
    func packSigned(_ messageData: NSDictionary,
                      signBy: NSString,
                      resolversId: NSString,
                      resolve: @escaping RCTPromiseResolveBlock,
                      reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called packSigned")

        do {
            let message = try Message(fromJson: messageData)
            let (didResolver, secretsResolver) = createResolvers(with: resolversId)
            let delegate = DidPromise(resolve, reject)
            
            let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
                .packSigned(msg: message,
                            signBy: signBy.asString,
                            cb: delegate)
        } catch DecodeError.error(let msg) {
            reject("Decode derror:", msg, DecodeError.error(msg))
            return
        } catch {
            reject("Unknown error.", error.localizedDescription, error)
            return
        }
    }
    
    @objc(packPlaintext: resolversId:withResolver:withRejecter:)
    func packPlaintext(_ messageData: NSDictionary,
                         resolversId: NSString,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called packPlaintext")
           
        do {
            let message = try Message(fromJson: messageData)
            let (didResolver, secretsResolver) = createResolvers(with: resolversId)
            let delegate = DidPromise(resolve, reject)
            
            let _ = DidComm(didResolver: didResolver,
                            secretResolver: secretsResolver)
                .packPlaintext(msg: message,
                               cb: delegate)
        } catch DecodeError.error(let msg) {
            reject("Decode derror:", msg, DecodeError.error(msg))
            return
        } catch {
            reject("Unknown error.", error.localizedDescription, error)
            return
        }
    }
    
    @objc(unpack:optionsJson:resolversId:withResolver:withRejecter:)
    func unpack(_ packedMsg: NSString,
                  optionsJson: NSString? = nil,
                  resolversId: NSString,
                  resolve: @escaping RCTPromiseResolveBlock,
                  reject: @escaping RCTPromiseRejectBlock) {
        
        print("[MessageHelpersModule] - Called unpack")

        let (didResolver, secretsResolver) = createResolvers(with: resolversId)
        let delegate = DidPromise(resolve, reject)
        let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
            .unpack(msg: packedMsg.asString,
                    options: .init(fromJson: optionsJson),
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
        
        do {
            let encAlgAnon = try AnonCryptAlg.fromString(jsAnonCryptAlg.asString)
            let (didResolver, secretsResolver) = createResolvers(with: resolversId)
            let delegate = DidWrapPromise(resolve, reject)
            
            let _ = DidComm(didResolver: didResolver, secretResolver: secretsResolver)
                .wrapInForward(msg: message.asString,
                               headers: headers as? [String: String] ?? [:],
                               to: to.asString,
                               routingKeys: routingKeys as? [String] ?? [],
                               encAlgAnon: encAlgAnon,
                               cb: delegate)
        } catch DecodeError.error(let msg) {
            reject("Decode derror:", msg, DecodeError.error(msg))
            return
        } catch {
            reject("Unknown error.", error.localizedDescription, error)
            return
        }
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
        reject(msg, err.localizedDescription, err)
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
        print("[MessageHelpersModule] - Error: ", msg)
        reject(msg, err.localizedDescription, err)
    }
}

