//
// Copyright (c) 2016 Ryan
//

#define FACEBOOK_LOGIN_ENABLED

#import "FObject.h"

#ifdef FACEBOOK_LOGIN_ENABLED
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FUser : FObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Class methods

+ (NSString *)currentId;

+ (FUser *)currentUser;

+ (instancetype)userWithId:(NSString *)uid;

+ (void)signInWithEmail:(NSString *)email password:(NSString *)password
			 completion:(void (^)(FUser *user, NSError *error))completion;

+ (void)createUserWithEmail:(NSString *)email password:(NSString *)password
				 completion:(void (^)(FUser *user, NSError *error))completion;

+ (void)signInWithFacebook:(UIViewController *)viewController
				completion:(void (^)(FUser *user, NSError *error))completion;

+ (BOOL)logOut;

#pragma mark - Instance methods

- (BOOL)isCurrent;

@end

NS_ASSUME_NONNULL_END

