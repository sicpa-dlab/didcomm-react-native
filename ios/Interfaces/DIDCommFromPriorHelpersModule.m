#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface RCT_EXTERN_MODULE(DIDCommFromPriorHelpersModule, NSObject)


RCT_EXTERN_METHOD(pack:(NSDictionary *)fromPriorData
                  issuerKid:(NSString *)issuerKid
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(unpack:(NSString *)fromPriorJwt
                  resolversId:(NSString *)resolversId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}


@end
