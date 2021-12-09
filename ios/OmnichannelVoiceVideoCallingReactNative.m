#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(OmnichannelVoiceVideoCallingReactNative, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString)callingToken
                  withRequestId:(NSString)requestId
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(acceptCall:(BOOL)withVideo
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isMicrophoneMuted:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(toggleMute:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isRemoteVideoEnabled:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isLocalVideoEnabled:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(rejectCall)

RCT_EXTERN_METHOD(stopCall)

RCT_EXTERN_METHOD(toggleSpeaker)

RCT_EXTERN_METHOD(toggleLocalVideo)

RCT_EXTERN_METHOD(toggleCamera)

@end

@interface RCT_EXTERN_MODULE(LocalVideoViewManager, RCTViewManager)
@end

@interface RCT_EXTERN_MODULE(RemoteVideoViewManager, RCTViewManager)
@end
