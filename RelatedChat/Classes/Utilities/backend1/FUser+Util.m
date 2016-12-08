//
// Copyright (c) 2016 Ryan
//

#import "AppConstant.h"

#import "FUser+Util.h"

@implementation FUser (Util)

#pragma mark - Class methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)fullname				{	return [[FUser currentUser] fullname];					}
+ (NSString *)initials				{	return [[FUser currentUser] initials];					}
+ (NSString *)picture				{	return [[FUser currentUser] picture];					}
+ (NSString *)status				{	return [[FUser currentUser] status];					}
+ (NSString *)loginMethod			{	return [[FUser currentUser] loginMethod];				}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSInteger)keepMedia				{	return [[FUser currentUser] keepMedia];					}
+ (NSInteger)networkImage			{	return [[FUser currentUser] networkImage];				}
+ (NSInteger)networkVideo			{	return [[FUser currentUser] networkVideo];				}
+ (NSInteger)networkAudio			{	return [[FUser currentUser] networkAudio];				}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)autoSaveMedia				{	return [[FUser currentUser] autoSaveMedia];				}
+ (BOOL)isOnboardOk					{	return [[FUser currentUser] isOnboardOk];				}
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Instance methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)fullname				{	return self[FUSER_FULLNAME];							}
- (NSString *)picture				{	return self[FUSER_PICTURE];								}
- (NSString *)status				{	return self[FUSER_STATUS];								}
- (NSString *)loginMethod			{	return self[FUSER_LOGINMETHOD];							}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)keepMedia				{	return [self[FUSER_KEEPMEDIA] integerValue];			}
- (NSInteger)networkImage			{	return [self[FUSER_NETWORKIMAGE] integerValue];			}
- (NSInteger)networkVideo			{	return [self[FUSER_NETWORKVIDEO] integerValue];			}
- (NSInteger)networkAudio			{	return [self[FUSER_NETWORKAUDIO] integerValue];			}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)autoSaveMedia				{	return [self[FUSER_AUTOSAVEMEDIA] boolValue];			}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isOnboardOk					{	return (self[FUSER_FULLNAME] != nil);					}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)initials
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([self[FUSER_FIRSTNAME] length] != 0) && ([self[FUSER_LASTNAME] length] != 0))
		return [NSString stringWithFormat:@"%@%@", [self[FUSER_FIRSTNAME] substringToIndex:1], [self[FUSER_LASTNAME] substringToIndex:1]];
	return nil;
}

@end

