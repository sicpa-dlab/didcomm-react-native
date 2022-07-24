#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(DIDCommResolversProxyModule, NSObject)

    RCT_EXTERN_METHOD(setResolvedDid:(NSString *)jsonValue
                      resolversId:(NSString *)resolversId)

    RCT_EXTERN_METHOD(setFoundSecret:(NSString *)jsonValue
                      resolversId:(NSString *)resolversId)

    RCT_EXTERN_METHOD(setFoundSecretIds:(NSString *)jsonValue
                      resolversId:(NSString *)resolversId)

    RCT_EXTERN_METHOD(supportedEvents)
    RCT_EXTERN_METHOD(startObserving)
    RCT_EXTERN_METHOD(stopObserving)

    RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getName)
    {
        return @"DIDCommResolversProxyModule";
    }

    + (BOOL)requiresMainQueueSetup
    {
      return YES;
    }

    - (NSDictionary *)constantsToExport
    {
      return @{ @"DID_STRING_KEY": @"did",
                @"KID_STRING_KEY": @"kid",
                @"KIDS_STRING_KEY": @"kids",
                @"RESOLVERS_ID_STRING_KEY": @"resolversId",
      };
    }

@end
