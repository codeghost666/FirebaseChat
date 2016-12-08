//
// Copyright (c) 2016 Ryan
//

#import <Realm/Realm.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DBUser : RLMObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property NSString *objectId;

@property NSString *email;
@property NSString *firstname;
@property NSString *lastname;
@property NSString *fullname;
@property NSString *country;
@property NSString *location;
@property NSString *status;
@property NSString *loginMethod;
@property NSString *oneSignalId;

@property NSString *picture;
@property NSString *thumbnail;

@property NSInteger keepMedia;
@property NSInteger networkImage;
@property NSInteger networkVideo;
@property NSInteger networkAudio;

@property BOOL autoSaveMedia;

@property NSTimeInterval createdAt;
@property NSTimeInterval updatedAt;

- (NSString *)initials;

@end

