/* RNEventEmitter.m */

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(RNEventEmitter, RCTEventEmitter)
    
    RCT_EXTERN_METHOD(supportedEvents)
    RCT_EXTERN_METHOD(startObserving)
    RCT_EXTERN_METHOD(stopObserving)

    + (BOOL)requiresMainQueueSetup
    {
      return YES;
    }

@end
