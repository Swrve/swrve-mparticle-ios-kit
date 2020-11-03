#import "MPKitSwrve.h"

/* Import your header file here
*/
#if defined(__has_include) && __has_include(<SwrveSDK/SwrveSDK.h>)
#import <SwrveSDK/SwrveSDK.h>
#else
#import "SwrveSDK.h"
#endif

NSString *const SwrveMParticleVersionNumber = @"2.0.0";

@implementation MPKitSwrve
/*
    mParticle will supply a unique kit code for you. Please contact our team
*/
+ (NSNumber *)kitCode {
    return @1145;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Swrve" className:@"MPKitSwrve"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - private methods for MPKitSwrve identity calls
- (void) startSwrveSDK:(FilteredMParticleUser*) user {
    NSString* user_id;
    if (_user_id_type == 100) {
        user_id = user.userId.stringValue;
        if (![SwrveSDK started] || SwrveSDK.userID != user_id){
            [SwrveSDK startWithUserId:user_id];
            self->_init_called = YES;
            return;
        }
    } else {
        if ([user.userIdentities objectForKey:@(_user_id_type)]){
            user_id = user.userIdentities[@(_user_id_type)];
            if(![SwrveSDK started] || SwrveSDK.userID != user_id){
                [SwrveSDK startWithUserId:user_id];
                self->_init_called = YES;
                return;
            }
        }
    }
}

- (void) identifySwrveUser:(FilteredMParticleUser*) user {
    NSString* external_user_id;
    if (_user_id_type == 100){
        external_user_id = user.userId.stringValue;
        if ([[SwrveSDK externalUserId]  isEqual: @""] || [SwrveSDK externalUserId] != external_user_id) {
            [SwrveSDK identify:external_user_id onSuccess:^(NSString *status, NSString* swrveUserId){
                DebugLog(@"Swrve Identity call successful. External ID: %@ . Status: %@ . Swrve User ID: %@", external_user_id, status, swrveUserId );
            } onError:^(NSInteger httpCode, NSString *errorMessage){
                DebugLog(@"Swrve Identity call failed with code %li . Message: %@", (long)httpCode, errorMessage);
            }];
            self->_init_called = YES;
            return;
        }

    } else {
        if (user.userIdentities[@(_user_id_type)]){
            external_user_id = user.userIdentities[@(_user_id_type)];
            if([[SwrveSDK externalUserId] isEqual: @""] || [SwrveSDK externalUserId] != external_user_id) {
                [SwrveSDK identify:external_user_id onSuccess:^(NSString *status, NSString* swrveUserId){
                    DebugLog(@"Swrve Identity call successful. External ID: %@ . Status: %@ . Swrve User ID: %@", external_user_id, status, swrveUserId );
                } onError:^(NSInteger httpCode, NSString *errorMessage){
                    DebugLog(@"Swrve Identity call failed with code %li . Message: %@", (long)httpCode, errorMessage);
                }];
                self->_init_called = YES;
                return;
            }
        }
    }
}

- (void) identityMethodsStart:(FilteredMParticleUser*) user {
    if (_init_mode == SWRVE_INIT_MODE_MANAGED) {
        [self startSwrveSDK:user];
    }
    if (_init_mode == SWRVE_INIT_MODE_AUTO) {
        [self identifySwrveUser:user];
    }
}


#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    DebugLog(@"MPKitSwrve : configuration: %@", configuration);
    int appId = [configuration[@"app_id"] intValue];
    NSString *apiKey = configuration[@"api_key"];
    if (!apiKey || !appId) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    
    self->_init_mode = SWRVE_INIT_MODE_MANAGED;
    if ([configuration objectForKey:@"initialization_mode"]) {
        self->_init_mode = [configuration[@"initialization_mode"] isEqual:@"AUTO"] ? SWRVE_INIT_MODE_AUTO : SWRVE_INIT_MODE_MANAGED;
    }
    if (self->_init_mode == SWRVE_INIT_MODE_MANAGED ){
        self->_user_id_type = 100;
        if ([configuration objectForKey:@"swrve_user_id"]){
            self->_user_id_type = [configuration[@"swrve_user_id"] isEqual:@"MPID"] ? 100 : MPUserIdentityCustomerId;
        }
    }
    if (self->_init_mode == SWRVE_INIT_MODE_AUTO){
        self->_user_id_type = MPUserIdentityCustomerId;
        if ([configuration objectForKey:@"external_user_id"]){
            NSString *user_type = configuration[@"external_user_id"];
            if ([user_type isEqualToString:@"MPID"]) {
                self->_user_id_type = 100;
            } else if ([user_type isEqualToString:@"Customer ID"]) {
                self->_user_id_type = MPUserIdentityCustomerId;
            } else if ([user_type isEqualToString:@"Other"]) {
                self->_user_id_type = MPUserIdentityOther;
            } else if ([user_type isEqualToString:@"Other2"]) {
                self->_user_id_type = MPUserIdentityOther2;
            } else if ([user_type isEqualToString:@"Other3"]) {
                self->_user_id_type = MPUserIdentityOther3;
            } else if ([user_type isEqualToString:@"Other4"]) {
                self->_user_id_type = MPUserIdentityOther4;
            } else if ([user_type isEqualToString:@"Other5"]) {
                self->_user_id_type = MPUserIdentityOther5;
            } else if ([user_type isEqualToString:@"Other6"]) {
                self->_user_id_type = MPUserIdentityOther6;
            } else if ([user_type isEqualToString:@"Other7"]) {
                self->_user_id_type = MPUserIdentityOther7;
            } else if ([user_type isEqualToString:@"Other8"]) {
                self->_user_id_type = MPUserIdentityOther8;
            } else if ([user_type isEqualToString:@"Other9"]) {
                self->_user_id_type = MPUserIdentityOther9;
            } else if ([user_type isEqualToString:@"Other10"]) {
                self->_user_id_type = MPUserIdentityOther10;
            }
        }
    }
    
    _configuration = configuration;
    _started=NO;


    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)start {
    _init_called=NO;
    /*
        Start your SDK here. The configuration dictionary can be retrieved from self->_configuration
    */
    static dispatch_once_t swrvePredicate;
    
    dispatch_once(&swrvePredicate, ^{
        int appId = [self->_configuration[@"app_id"] intValue];
        NSString *apiKey = self->_configuration[@"api_key"];
        SwrveConfig* config = [[SwrveConfig alloc] init];
        if ([self->_configuration objectForKey:@"swrve_stack"]){
            NSString *stack = self->_configuration[@"swrve_stack"];
            if ([stack isEqual:@"EU"]){
                config.stack = SWRVE_STACK_EU;
            }
        }
        config.initMode = self->_init_mode;
        config.pushResponseDelegate = self;
        config.pushEnabled = YES;
        config.autoCollectDeviceToken = NO;
        config.pushNotificationEvents = [[NSSet alloc] initWithArray:@[@"other.swrve_push_opt_in"]];
        config.appGroupIdentifier = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        [SwrveSDK sharedInstanceWithAppID: appId
                                   apiKey: apiKey
                                   config: config];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
        });
    self->_started=YES; // if not set to YES here, identity calls not sent to Swrve later
    });
}

- (id const)providerKitInstance {
    return [self init_called] ? [SwrveSDK sharedInstance] : nil;
}


#pragma mark Application
/*
    Implement this method if your SDK handles a user interacting with a remote notification action
*/
// - (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//     return [self execStatus:MPKitReturnCodeSuccess];
// }
//
///*
//    Implement this method if your SDK receives and handles remote notifications
//*/
// - (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

/*
    Implement this method if your SDK registers the device token for remote notifications
*/
 - (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK setDeviceToken:deviceToken];
    return [self execStatus:MPKitReturnCodeSuccess];
 }

- (MPKitExecStatus *)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
    [self willPresentNotification:notification withCompletionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];

}

- (MPKitExecStatus *)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response API_AVAILABLE(ios(10.0)){
    [self didReceiveNotificationResponse:response withCompletionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}


/** SwrvePushResponseDelegate
    Implement the following methods if you want to interact with a push action reponse
 **/

- (void) didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){

    NSLog(@"MPKitSwrve : didRecieveNotificationResponse was fired with the following push response: %@", response.actionIdentifier);

    if(completionHandler) {
        completionHandler();
    }
}

/** SwrvePushResponseDelegate
 Implement the following method if you want to determine the display type of a push in the foreground
 **/

- (void) willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){

    if(completionHandler) {
        completionHandler(UNNotificationPresentationOptionNone);
    }
}


/*
    Implement this method if your SDK handles continueUserActivity method from the App Delegate
*/
// - (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

/*
    Implement this method if your SDK handles the iOS 9 and above App Delegate method to open URL with options
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK handleDeeplink:url];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

/*
    Implement this method if your SDK handles the iOS 8 and below App Delegate method open URL
*/
 - (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     [SwrveSDK handleDeeplink:url];
     return [self execStatus:MPKitReturnCodeSuccess];
 }

#pragma mark User attributes
/*
    Implement this method if your SDK allows for incrementing numeric user attributes.
*/
-(MPKitExecStatus *)incrementUserAttribute:(NSString *)key byValue:(NSNumber *)value {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIncrementUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    if (_init_mode == SWRVE_INIT_MODE_MANAGED) {
        [self startSwrveSDK:user];
    }
    return [SwrveSDK userUpdate: user.userAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

/*
    Implement this method if your SDK resets user attributes.
*/
//- (MPKitExecStatus *)onRemoveUserAttribute:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

/*
    Implement this method if your SDK sets user attributes.
*/


//no-op due to bug in mParticle callback
- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(id)value {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    NSDictionary* props=@{key:@""};
    return [SwrveSDK userUpdate:props] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

- (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    if (_init_mode == SWRVE_INIT_MODE_MANAGED) {
        [self startSwrveSDK:user];
    }
    return [SwrveSDK userUpdate: user.userAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
}

/*
    Implement this method if your SDK supports setting value-less attributes
*/
//- (MPKitExecStatus *)onSetUserTag:(FilteredMParticleUser *)user {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

#pragma mark Identity
/*
    Implement this method if your SDK should be notified any time the mParticle ID (MPID) changes. This will occur on initial install of the app, and potentially after a login or logout.
*/

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    [self identityMethodsStart:user];

    [SwrveSDK userUpdate:@{@"swrve.mparticle_ios_integration_version":SwrveMParticleVersionNumber}];
    [SwrveSDK sendQueuedEvents];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when the user logs in
*/
- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    [self identityMethodsStart:user];

    [SwrveSDK userUpdate:@{@"swrve.mparticle_ios_integration_version":SwrveMParticleVersionNumber}];
    [SwrveSDK sendQueuedEvents];

     return [self execStatus:MPKitReturnCodeSuccess];
}

/*
    Implement this method if your SDK should be notified when the user logs out
*/
//- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
//}

/*
    Implement this method if your SDK should be notified when user identities change
*/
- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
    [self identityMethodsStart:user];

    [SwrveSDK userUpdate:@{@"swrve.mparticle_ios_integration_version":SwrveMParticleVersionNumber}];
    [SwrveSDK sendQueuedEvents];
     return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark e-Commerce
/*
    Implement this method if your SDK supports commerce events.
    If your SDK does support commerce event, but does not support all commerce event actions available in the mParticle SDK,
    expand the received commerce event into regular events and log them accordingly (see sample code below)
    Please see MPCommerceEvent.h > MPCommerceEventAction for complete list
*/
 - (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
     MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess forwardCount:0];
     NSString* currency = commerceEvent.currency ? : @"USD";

     // In this example, this SDK only supports the 'Purchase' commerce event action
     if (commerceEvent.action == MPCommerceEventActionPurchase) {
             /* Your code goes here. */
         
         for (MPProduct *product in commerceEvent.products) {
             SwrveIAPRewards* rewards = [[SwrveIAPRewards alloc] init];
             [SwrveSDK unvalidatedIap:rewards localCost:[product.price doubleValue] localCurrency:currency productId:product.sku productIdQuantity:[product.quantity intValue]];
             [execStatus incrementForwardCount];
         }
     } else { // Other commerce events are expanded and logged as regular events
         NSArray *expandedInstructions = [commerceEvent expandedInstructions];

         for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
             [self logBaseEvent:commerceEventInstruction.event];
             [execStatus incrementForwardCount];
         }
     }

     return execStatus;
 }

#pragma mark Events
/*
    Implement this method if your SDK logs user events.
    Please see MPEvent.h
*/
- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
        return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@1145 returnCode:MPKitReturnCodeUnavailable];
    }
}

 - (MPKitExecStatus *)routeEvent:(MPEvent *)event {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     if (event.type == MPEventTypeOther) {
         if ( [event.customAttributes valueForKey:@"given_currency"] && [event.customAttributes valueForKey:@"given_amount"] ) {
             NSString* givenCurrency = [event.customAttributes valueForKey:@"given_currency"];
             NSNumber* givenAmount = [event.customAttributes valueForKey:@"given_amount"];
             return [SwrveSDK currencyGiven:givenCurrency givenAmount:[givenAmount doubleValue]] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
         }
     }
     return [SwrveSDK event:[NSString stringWithFormat:@"%@.%@", [event.typeName lowercaseString], event.name] payload:event.customAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
 }

/*
    Implement this method if your SDK logs screen events
    Please see MPEvent.h
*/
 - (MPKitExecStatus *)logScreen:(MPEvent *)event {
     /*  Your code goes here.
         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
         Please see MPKitExecStatus.h for all exec status codes
      */
     NSString* screen_name=event.name;
     NSString* event_name=[NSString stringWithFormat:@"screen_view.%@", screen_name];
     return [SwrveSDK event:event_name payload:event.customAttributes] == SWRVE_SUCCESS ? [self execStatus:MPKitReturnCodeSuccess] : [self execStatus:MPKitReturnCodeFail];
 }

#pragma mark Assorted
/*
    Implement this method if your SDK implements an opt out mechanism for users.
*/
// - (MPKitExecStatus *)setOptOut:(BOOL)optOut {
//     /*  Your code goes here.
//         If the execution is not successful, please use a code other than MPKitReturnCodeSuccess for the execution status.
//         Please see MPKitExecStatus.h for all exec status codes
//      */
//
//     return [self execStatus:MPKitReturnCodeSuccess];
// }

@end
