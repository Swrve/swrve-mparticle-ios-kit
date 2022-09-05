#import <XCTest/XCTest.h>
#import "MPKitSwrve.h"
#import <OCMock/OCMock.h>
#import "SwrveSDK.h"

@interface Swrve_mParticleTests : XCTestCase

@end

@interface MPKitSwrve ()

- (void)resetSwrvePredicate;
- (void)identityMethodsStart:(FilteredMParticleUser *)user;
- (void)startSwrveSDK:(FilteredMParticleUser *)user;
- (void)identifySwrveUser:(FilteredMParticleUser *)user;

@end

@interface SwrveSDK (InternalAccess)
+ (void)addSharedInstance:(Swrve *)instance;
+ (void)resetSwrveSharedInstance;
+ (void)sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString *)swrveAPIKey config:(SwrveConfig *)swrveConfig;
@end

@interface Swrve (InternalAccess)
- (BOOL)sdkReady;
- (BOOL)started;
@end

@implementation Swrve_mParticleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitSwrve kitCode], @1145);
}

- (void)testDidFinishLaunchingWithConfigurationMANAGED {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"MANAGED",
                                  @"swrve_stack" :@"EU",
                                  @"swrve_user_id" :@"Customer ID",
                                  @"external_user_id" :@"Other"
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];
    XCTAssertFalse(swrveKit.started);
    XCTAssertFalse(swrveKit.init_called);
    XCTAssertEqual(swrveKit.init_mode, SWRVE_INIT_MODE_MANAGED);
    XCTAssertEqual(swrveKit.user_id_type, MPUserIdentityCustomerId);

    XCTAssertEqualObjects(swrveKit.configuration, testValues);

    id config = [OCMArg checkWithBlock:^BOOL(SwrveConfig *config)  {
        XCTAssertEqual(config.stack, SWRVE_STACK_EU);
        XCTAssertTrue(config.pushEnabled);
        XCTAssertFalse(config.autoCollectDeviceToken);
        XCTAssertEqual(config.initMode, SWRVE_INIT_MODE_MANAGED);
        XCTAssertEqualObjects(config.pushResponseDelegate, swrveKit);
        XCTAssertEqualObjects(config.pushNotificationEvents, [[NSSet alloc] initWithArray:@[@"other.swrve_push_opt_in"]]);
        XCTAssertEqualObjects(config.appGroupIdentifier, [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]);
        return true;
    }];

    OCMExpect([swrveSDKMock sharedInstanceWithAppID:12345
                                          apiKey:@"ABCDE"
                                             config:config]);

    [(MPKitSwrve *)swrveKitMock start];

    XCTAssertFalse(swrveKit.init_called);
    XCTAssertTrue(swrveKit.started);

    [swrveSDKMock verifyWithDelay:2];
    [swrveKit resetSwrvePredicate];
}

//Note: due to
- (void)testDidFinishLaunchingWithConfigurationAUTO {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveSDKMock = [self mockSwrveSDK];

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"AUTO",
                                  @"swrve_stack" :@"US",
                                  @"swrve_user_id" :@"Customer ID",
                                  @"external_user_id" :@"MPID"
    };

    [swrveKit didFinishLaunchingWithConfiguration:testValues];
    XCTAssertFalse(swrveKit.started);
    XCTAssertFalse(swrveKit.init_called);
    XCTAssertEqual(swrveKit.init_mode, SWRVE_INIT_MODE_AUTO);
    XCTAssertEqual(swrveKit.user_id_type, 100);

    XCTAssertEqualObjects(swrveKit.configuration, testValues);

    id config = [OCMArg checkWithBlock:^BOOL(SwrveConfig *config)  {
        XCTAssertEqual(config.stack, SWRVE_STACK_US);
        XCTAssertTrue(config.pushEnabled);
        XCTAssertFalse(config.autoCollectDeviceToken);
        XCTAssertEqual(config.initMode, SWRVE_INIT_MODE_AUTO);
        XCTAssertEqualObjects(config.pushResponseDelegate, swrveKit);
        XCTAssertEqualObjects(config.pushNotificationEvents, [[NSSet alloc] initWithArray:@[@"other.swrve_push_opt_in"]]);
        XCTAssertEqualObjects(config.appGroupIdentifier, [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]);
        return true;
    }];
    
    OCMExpect([swrveSDKMock sharedInstanceWithAppID:12345
                                          apiKey:@"ABCDE"
                                             config:config]);
    [swrveKit start];

    XCTAssertFalse(swrveKit.init_called);
    XCTAssertTrue(swrveKit.started);

    [swrveSDKMock verifyWithDelay:2];
    [swrveKit resetSwrvePredicate];
}

- (void)testOpenURL {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSURL *url = [NSURL URLWithString:@"url"];
    OCMExpect([swrveMock handleDeeplink:url]);
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPKitExecStatus *execStatus = [kit openURL:url options:OCMOCK_ANY];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    
    OCMVerifyAll(swrveMock);
}

- (void)testOpenURLSource {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSURL *url = [NSURL URLWithString:@"urlx"];
    OCMExpect([swrveMock handleDeeplink:url]);
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPKitExecStatus *execStatus = [kit openURL:url sourceApplication:OCMOCK_ANY annotation:OCMOCK_ANY];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    
    OCMVerifyAll(swrveMock);
}

- (void)testLogScreen {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSString *eventName = @"TestName";
    NSDictionary *payload =  @{ @"key_test":@"value_test"};
    NSString *expectedEventName = @"screen_view.TestName";
    OCMExpect([swrveMock event:expectedEventName payload:payload]);
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPEvent *event = [[MPEvent alloc] initWithName:eventName type:MPEventTypeOther];
    event.customAttributes = payload;
    
    MPKitExecStatus *execStatus = [kit logScreen:event];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    
    OCMVerifyAll(swrveMock);
}

- (void)testLogBaseMPEvent {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSString *eventName = @"TestName";
    NSDictionary *payload =  @{ @"key_test":@"value_test"};
    NSString *expectedEventName = @"other.TestName";
    OCMExpect([swrveMock event:expectedEventName payload:payload]);

    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPEvent *event = [[MPEvent alloc] initWithName:eventName type:MPEventTypeOther];
    event.customAttributes = payload;

    MPKitExecStatus *execStatus = [kit logBaseEvent:event];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
}

- (void)testLogBaseMPEventCurreny {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSString *eventName = @"TestName";
    NSDictionary *payload =  @{ @"given_currency":@"us", @"given_amount":@100};
    OCMExpect([swrveMock currencyGiven:@"us" givenAmount:100]);
        
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPEvent *event = [[MPEvent alloc] initWithName:eventName type:MPEventTypeOther];
    event.customAttributes = payload;
    
    MPKitExecStatus *execStatus = [kit logBaseEvent:event];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    
    OCMVerifyAll(swrveMock);
}

- (void)testLogBaseMPCommerceEvent {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPProduct *product1 = [[MPProduct alloc]initWithName:@"name1" sku:@"sku1" quantity:@100 price:@200];
    MPCommerceEvent *ecommcreEvent = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product1];
    MPProduct *product2 = [[MPProduct alloc]initWithName:@"name2" sku:@"sku2" quantity:@300 price:@400];
    [ecommcreEvent addProduct:product2];
    
    OCMExpect([swrveMock unvalidatedIap:[OCMArg isKindOfClass:[SwrveIAPRewards class]] localCost:200 localCurrency:@"USD" productId:@"sku1" productIdQuantity:100]);
    OCMExpect([swrveMock unvalidatedIap:[OCMArg isKindOfClass:[SwrveIAPRewards class]] localCost:400 localCurrency:@"USD" productId:@"sku2" productIdQuantity:300]);

    MPKitExecStatus *execStatus = [kit logBaseEvent:ecommcreEvent];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
}

- (void)testSetDeviceToken {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    NSString *testDataString = @"Test Data";
    NSData* testData = [testDataString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    OCMExpect([(Swrve *)swrveMock setDeviceToken:testData]);

    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    MPKitExecStatus *execStatus = [kit setDeviceToken:testData];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
}

- (void)testOnIdentifyComplete {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    id userUpdate = [OCMArg checkWithBlock:^BOOL(NSDictionary *attributes)  {
        XCTAssertEqualObjects(attributes[@"swrve.mparticle_ios_integration_version"], @"3.0.0");
        return true;
    }];
    
    FilteredMParticleUser *user = nil;
    FilteredMPIdentityApiRequest *request = nil;
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(kit);
   
    OCMExpect([(Swrve *)swrveMock userUpdate:userUpdate]);
    OCMExpect([swrveKitMock identityMethodsStart:user]);
    OCMExpect([(Swrve *)swrveMock sendQueuedEvents]);


    MPKitExecStatus *execStatus = [kit onIdentifyComplete:user request:request];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
    OCMVerifyAll(swrveKitMock);
}

- (void)testOnLoginComplete {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    id userUpdate = [OCMArg checkWithBlock:^BOOL(NSDictionary *attributes)  {
        XCTAssertEqualObjects(attributes[@"swrve.mparticle_ios_integration_version"], @"3.0.0");
        return true;
    }];
    
    FilteredMParticleUser *user = nil;
    FilteredMPIdentityApiRequest *request = nil;
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(kit);
   
    OCMExpect([(Swrve *)swrveMock userUpdate:userUpdate]);
    OCMExpect([swrveKitMock identityMethodsStart:user]);
    OCMExpect([(Swrve *)swrveMock sendQueuedEvents]);


    MPKitExecStatus *execStatus = [kit onLoginComplete:user request:request];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
    OCMVerifyAll(swrveKitMock);
}

- (void)testOnModifyComplete {
    id swrveMock = [self mockSwrve];
    OCMStub([swrveMock sdkReady]).andReturn(true);

    id userUpdate = [OCMArg checkWithBlock:^BOOL(NSDictionary *attributes)  {
        XCTAssertEqualObjects(attributes[@"swrve.mparticle_ios_integration_version"], @"3.0.0");
        return true;
    }];
    
    FilteredMParticleUser *user = nil;
    FilteredMPIdentityApiRequest *request = nil;
    
    MPKitSwrve *kit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(kit);
   
    OCMExpect([(Swrve *)swrveMock userUpdate:userUpdate]);
    OCMExpect([swrveKitMock identityMethodsStart:user]);
    OCMExpect([(Swrve *)swrveMock sendQueuedEvents]);


    MPKitExecStatus *execStatus = [kit onModifyComplete:user request:request];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);

    OCMVerifyAll(swrveMock);
    OCMVerifyAll(swrveKitMock);
}

- (void)testIdentityMethodsStartManaged {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"MANAGED",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = nil;
    OCMExpect([swrveKitMock startSwrveSDK:user]);
    
    [swrveKitMock identityMethodsStart:user];
    OCMVerifyAll(swrveKitMock);
}

- (void)testIdentityMethodsStartAuto {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"AUTO",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = nil;
    OCMExpect([swrveKitMock identifySwrveUser:user]);
    
    [swrveKitMock identityMethodsStart:user];
    OCMVerifyAll(swrveKitMock);
}

- (void)testStartSwrveSDKwithMPID {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    [swrveKit setValue:@100 forKey:@"user_id_type"];
   
    id swrveSDKMock = [self mockSwrveSDK];
    
    OCMStub([swrveSDKMock started]).andReturn(true);
    OCMStub([swrveSDKMock userID]).andReturn(@"differentUserID");

    XCTAssertFalse([swrveKitMock init_called]);
     
    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    OCMStub([filteredMParticleUserMock userId]).andReturn(@12345);
        
    OCMExpect([swrveSDKMock startWithUserId:@"12345"]);
    
    [swrveKit startSwrveSDK:filteredMParticleUserMock];
    XCTAssertTrue([swrveKitMock init_called]);
    
    OCMVerifyAll(swrveSDKMock);
}

- (void)testStartSwrveSDKwithCustomUserID {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    [swrveKit setValue:[NSNumber numberWithUnsignedInteger:MPUserIdentityCustomerId] forKey:@"user_id_type"];
   
    id swrveSDKMock = [self mockSwrveSDK];
    
    OCMStub([swrveSDKMock started]).andReturn(true);
    OCMStub([swrveSDKMock userID]).andReturn(@"differentUserID");

    XCTAssertFalse([swrveKitMock init_called]);
     
    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    OCMStub([filteredMParticleUserMock userIdentities]).andReturn(@{[NSNumber numberWithUnsignedInteger:MPUserIdentityCustomerId] : @"SomeCustomerID" });
        
    OCMExpect([swrveSDKMock startWithUserId:@"SomeCustomerID"]);
    
    [swrveKit startSwrveSDK:filteredMParticleUserMock];
    XCTAssertTrue([swrveKitMock init_called]);
    
    OCMVerifyAll(swrveSDKMock);
}

- (void)testIdentifySwrveUserwithMPID {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    [swrveKit setValue:@100 forKey:@"user_id_type"];
   
    id swrveSDKMock = [self mockSwrveSDK];

    OCMStub([swrveSDKMock externalUserId]).andReturn(@"differentUserID");

    XCTAssertFalse([swrveKitMock init_called]);
     
    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    OCMStub([filteredMParticleUserMock userId]).andReturn(@12345);
        
    OCMExpect([swrveSDKMock identify:@"12345" onSuccess:OCMOCK_ANY onError:OCMOCK_ANY]);
    
    [swrveKit identifySwrveUser:filteredMParticleUserMock];
    XCTAssertTrue([swrveKitMock init_called]);
    
    OCMVerifyAll(swrveSDKMock);
}

- (void)testIdentifySwrveUserwithCustomUserID {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    [swrveKit setValue:[NSNumber numberWithUnsignedInteger:MPUserIdentityCustomerId] forKey:@"user_id_type"];
   
    id swrveSDKMock = [self mockSwrveSDK];
    
    OCMStub([swrveSDKMock externalUserId]).andReturn(@"differentUserID");

    XCTAssertFalse([swrveKitMock init_called]);
     
    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    OCMStub([filteredMParticleUserMock userIdentities]).andReturn(@{[NSNumber numberWithUnsignedInteger:MPUserIdentityCustomerId] : @"SomeCustomerID" });
        
    OCMExpect([swrveSDKMock identify:@"SomeCustomerID" onSuccess:OCMOCK_ANY onError:OCMOCK_ANY]);
    
    [swrveKit identifySwrveUser:filteredMParticleUserMock];
    XCTAssertTrue([swrveKitMock init_called]);
    
    OCMVerifyAll(swrveSDKMock);
}

- (void)testOnIncrementUserAttributeManaged {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"MANAGED",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    NSDictionary *userAtt = @{@"key" : @"value"};
    OCMStub([filteredMParticleUserMock userAttributes]).andReturn(userAtt);
    
    OCMExpect([swrveSDKMock userUpdate:userAtt]);
    OCMExpect([swrveKitMock startSwrveSDK:user]);
   
    MPKitExecStatus *execStatus = [swrveKitMock onIncrementUserAttribute:user];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    OCMVerifyAll(swrveKitMock);
}

- (void)testOnIncrementUserAttributeAuto {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];
    
    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"AUTO",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    NSDictionary *userAtt = @{@"key" : @"value"};
    OCMStub([filteredMParticleUserMock userAttributes]).andReturn(userAtt);
    
    OCMExpect([swrveSDKMock userUpdate:userAtt]);
    OCMReject([swrveKitMock startSwrveSDK:OCMOCK_ANY]);

    MPKitExecStatus *execStatus = [swrveKitMock onIncrementUserAttribute:user];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    OCMVerifyAll(swrveSDKMock);
}

- (void)testOnSetUserAttributeAuto {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];
    
    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"AUTO",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    NSDictionary *userAtt = @{@"key" : @"value"};
    OCMStub([filteredMParticleUserMock userAttributes]).andReturn(userAtt);
    
    OCMExpect([swrveSDKMock userUpdate:userAtt]);
    OCMReject([swrveKitMock startSwrveSDK:OCMOCK_ANY]);

    MPKitExecStatus *execStatus = [swrveKitMock onSetUserAttribute:user];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    OCMVerifyAll(swrveSDKMock);
}

- (void)testOnSetUserAttributeManaged {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];

    NSDictionary *testValues = @{ @"app_id": @"12345",
                                  @"api_key": @"ABCDE",
                                  @"initialization_mode" :@"MANAGED",
    };

    [swrveKitMock didFinishLaunchingWithConfiguration:testValues];

    FilteredMParticleUser *user = [FilteredMParticleUser new];
    id filteredMParticleUserMock = OCMPartialMock(user);
    NSDictionary *userAtt = @{@"key" : @"value"};
    OCMStub([filteredMParticleUserMock userAttributes]).andReturn(userAtt);
    
    OCMExpect([swrveSDKMock userUpdate:userAtt]);
    OCMExpect([swrveKitMock startSwrveSDK:user]);
   
    MPKitExecStatus *execStatus = [swrveKitMock onSetUserAttribute:user];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    
    OCMVerifyAll(swrveKitMock);
}

- (void)testRemoveUserAttribute {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    id swrveKitMock = OCMPartialMock(swrveKit);
    id swrveSDKMock = [self mockSwrveSDK];

    OCMExpect([swrveSDKMock userUpdate:@{@"someKey":@""}]);

    MPKitExecStatus *execStatus = [(MPKitSwrve *)swrveKitMock removeUserAttribute:@"someKey"];
    XCTAssertEqual(execStatus.returnCode, MPKitReturnCodeSuccess);
    OCMVerifyAll(swrveSDKMock);
}

#pragma mark Helpers

- (id)mockSwrveSDK {
    id swrveMock = OCMClassMock([SwrveSDK class]);
    return swrveMock;
}

- (id)mockSwrve {
    [SwrveSDK resetSwrveSharedInstance];
    Swrve *swrve = [Swrve alloc];
    id swrveMock = OCMPartialMock(swrve);
    [SwrveSDK addSharedInstance:swrveMock];
    return swrveMock;
}

@end
