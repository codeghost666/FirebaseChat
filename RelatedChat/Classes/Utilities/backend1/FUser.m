//
// Copyright (c) 2016 Ryan
//

#import "FUser.h"
#import "NSError+Util.h"

@implementation FUser

#pragma mark - Class methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)currentId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [FIRAuth auth].currentUser.uid;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (FUser *)currentUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FIRAuth auth].currentUser != nil)
	{
		NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"];
		return [[FUser alloc] initWithPath:@"User" dictionary:dictionary];
	}
	return nil;
}

#pragma mark - Initialization methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (instancetype)userWithId:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [[FUser alloc] initWithPath:@"User"];
	user[@"objectId"] = userId;
	return user;
}

#pragma mark - Email methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser *firuser, NSError *error)
	{
		if (error == nil)
		{
			[FUser load:firuser completion:^(FUser *user, NSError *error)
			{
				if (error == nil)
				{
					if (completion != nil) completion(user, nil);
				}
				else
				{
					[[FIRAuth auth] signOut:nil];
					if (completion != nil) completion(nil, error);
				}
			}];
		}
		else if (completion != nil) completion(nil, error);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createUserWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRUser *firuser, NSError *error)
	{
		if (error == nil)
		{
			[FUser create:firuser.uid email:email completion:^(FUser *user, NSError *error)
			{
				if (error == nil)
				{
					if (completion != nil) completion(user, nil);
				}
				else
				{
					[firuser deleteWithCompletion:^(NSError *error)
					{
						if (error != nil) [[FIRAuth auth] signOut:nil];
					}];
					if (completion != nil) completion(nil, error);
				}
			}];
		}
		else if (completion != nil) completion(nil, error);
	}];
}

#pragma mark - Facebook methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)signInWithFacebook:(UIViewController *)viewController completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
#ifdef FACEBOOK_LOGIN_ENABLED
	FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
	NSArray *permissions = @[@"public_profile", @"email", @"user_friends"];
	[login logInWithReadPermissions:permissions fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
	{
		if (error == nil)
		{
			if (result.isCancelled == NO)
			{
				NSString *accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
				FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
				[self signInWithCredential:credential completion:completion];
			}
			else if (completion != nil) completion(nil, nil);
		}
		else if (completion != nil) completion(nil, error);
	}];
#else
	if (completion != nil) completion(nil, [NSError description:@"Facebook login is not enabled." code:100]);
#endif
}

#pragma mark - Credential methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)signInWithCredential:(FIRAuthCredential *)credential completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *firuser, NSError *error)
	{
		if (error == nil)
		{
			[FUser load:firuser completion:^(FUser *user, NSError *error)
			{
				if (error == nil)
				{
					if (completion != nil) completion(user, nil);
				}
				else
				{
					[[FIRAuth auth] signOut:nil];
					if (completion != nil) completion(nil, error);
				}
			}];
		}
		else if (completion != nil) completion(nil, error);
	}];
}

#pragma mark - Logut methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)logOut
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	[[FIRAuth auth] signOut:&error];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (error == nil)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentUser"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return NO;
}

#pragma mark - Private methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)load:(FIRUser *)firuser completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser userWithId:firuser.uid];
	[user fetchInBackground:^(NSError *error)
	{
		if (error != nil)
		{
			[self create:firuser.uid email:firuser.email completion:completion];
		}
		else if (completion != nil) completion(user, nil);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)create:(NSString *)uid email:(NSString *)email completion:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser userWithId:uid];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (email != nil) user[@"email"] = email;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[user saveInBackground:^(NSError *error)
	{
		if (error == nil)
		{
			if (completion != nil) completion(user, nil);
		}
		else if (completion != nil) completion(nil, error);
	}];
}

#pragma mark - Instance methods

#pragma mark - Current user methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isCurrent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [self[@"objectId"] isEqualToString:[FUser currentId]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveLocalIfCurrent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self isCurrent])
	{
		[[NSUserDefaults standardUserDefaults] setObject:self.dictionary forKey:@"CurrentUser"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark - Save methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveInBackground
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self saveLocalIfCurrent];
	[super saveInBackground];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveInBackground:(void (^)(NSError *error))block
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self saveLocalIfCurrent];
	[super saveInBackground:^(NSError *error)
	{
		if (error == nil) [self saveLocalIfCurrent];
		if (block != nil) block(error);
	}];
}

#pragma mark - Fetch methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)fetchInBackground
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super fetchInBackground:^(NSError *error)
	{
		if (error == nil) [self saveLocalIfCurrent];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)fetchInBackground:(void (^)(NSError *error))block
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super fetchInBackground:^(NSError *error)
	{
		if (error == nil) [self saveLocalIfCurrent];
		if (block != nil) block(error);
	}];
}

@end

