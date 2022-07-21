#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface RCT_EXTERN_MODULE(DIDCommMessageHelpersModule, NSObject)

RCT_EXTERN_METHOD(packEncrypted:(NSDictionary *)messageData
                  to:(NSString *)to
                  from:(NSString *)from
                  signFrom:(NSString *)signFrom
                  protectSender:(BOOL)protectSender
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(packSigned:(NSDictionary *)messageData
                  signBy:(NSString *)signBy
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(packPlainText:(NSDictionary *)messageData
                  signBy:(NSString *)signBy
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}


@end
