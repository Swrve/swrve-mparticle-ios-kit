#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#if defined(__has_include) && __has_include(<SwrveSDKCommon/SwrvePush.h>)
#import <SwrveSDKCommon/SwrvePush.h>
#else
#import "SwrvePush.h"
#endif
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

#if defined(__has_include) && __has_include(<SwrveSDK/SwrveDeeplinkDelegate.h>)
#import <SwrveSDK/SwrveDeeplinkDelegate.h>
#else
#import "SwrveDeeplinkDelegate.h"
#endif

@interface MPKitSwrve : NSObject <MPKitProtocol, SwrvePushResponseDelegate, SwrveDeeplinkDelegate>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, unsafe_unretained, readonly) BOOL init_called;
@property (nonatomic, unsafe_unretained, readonly) int init_mode;
@property (nonatomic, unsafe_unretained, readonly) NSUInteger user_id_type;

@end
