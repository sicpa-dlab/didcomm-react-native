#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface RCT_EXTERN_MODULE(DIDCommMessageHelpersModule, NSObject)

RCT_EXTERN_METHOD(packEncrypted:(NSDictionary *)messageData
                  to:(NSString *)to
                  from:(NSString *)from
                  signFrom:(NSString *)signFrom
                  optionsJson:(NSString *)optionsJson
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(packSigned:(NSDictionary *)messageData
                  signBy:(NSString *)signBy
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(packPlaintext:(NSDictionary *)messageData
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

    
RCT_EXTERN_METHOD(unpack:(NSString *)packedMsg
                  optionsJson:(NSString *)optionsJson
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(wrapInForward:(NSString *)message
                  headers:(NSDictionary *)headers
                  to:(NSString *)to
                  routingKeys:(NSArray *)routingKeys
                  jsAnonCryptAlg:(NSString *)jsAnonCryptAlg
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}


@end
