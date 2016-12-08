//
// Copyright (c) 2016 Ryan
//

#import "FUser.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FUser (Util)
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Class methods

+ (NSString *)fullname;
+ (NSString *)initials;
+ (NSString *)picture;
+ (NSString *)status;
+ (NSString *)loginMethod;

+ (NSInteger)keepMedia;
+ (NSInteger)networkImage;
+ (NSInteger)networkVideo;
+ (NSInteger)networkAudio;

+ (BOOL)autoSaveMedia;
+ (BOOL)isOnboardOk;

#pragma mark - Instance methods

- (NSString *)initials;

@end

