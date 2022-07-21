import Foundation

@objc(DIDCommFromPriorHelpersModule)
class DIDCommFromPriorHelpersModule : NSObject {
    
    @objc(pack:issuerKid:resolversId:resolve:reject:)
    func pack(fromPriorData: NSDictionary,
              issuerKid: NSString,
              resolversId: NSString,
              resolve: RCTPromiseResolveBlock,
              reject: RCTPromiseRejectBlock) {
        
    }
    
    @objc(unpack:resolversId:resolve:reject:)
    func unpack(fromPriorJwt: NSString,
                resolversId: NSString,
                resolve: RCTPromiseResolveBlock,
                reject: RCTPromiseRejectBlock) {
        
    }
}
