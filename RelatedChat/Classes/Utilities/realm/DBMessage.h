//
// Copyright (c) 2016 Ryan
//

#import <Realm/Realm.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DBMessage : RLMObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property NSString *objectId;

@property NSString *groupId;
@property NSString *senderId;
@property NSString *senderName;
@property NSString *senderInitials;

@property NSString *type;
@property NSString *text;

@property NSString *picture;
@property NSInteger picture_width;
@property NSInteger picture_height;
@property NSString *picture_md5;

@property NSString *video;
@property NSInteger video_duration;
@property NSString *video_md5;

@property NSString *audio;
@property NSInteger audio_duration;
@property NSString *audio_md5;

@property CLLocationDegrees latitude;
@property CLLocationDegrees longitude;

@property NSString *status;
@property BOOL isDeleted;

@property NSTimeInterval createdAt;
@property NSTimeInterval updatedAt;

@end

