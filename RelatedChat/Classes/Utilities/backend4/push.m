//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification1(FObject *message)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *type = message[FMESSAGE_TYPE];
	NSString *text = message[FMESSAGE_SENDERNAME];
	NSString *groupId = message[FMESSAGE_GROUPID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:MESSAGE_TEXT])		text = [text stringByAppendingString:@" sent you a text message."];
	if ([type isEqualToString:MESSAGE_EMOJI])		text = [text stringByAppendingString:@" sent you an emoji."];
	if ([type isEqualToString:MESSAGE_PICTURE])		text = [text stringByAppendingString:@" sent you a picture."];
	if ([type isEqualToString:MESSAGE_VIDEO])		text = [text stringByAppendingString:@" sent you a video."];
	if ([type isEqualToString:MESSAGE_AUDIO])		text = [text stringByAppendingString:@" sent you an audio."];
	if ([type isEqualToString:MESSAGE_LOCATION])	text = [text stringByAppendingString:@" sent you a location."];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Recent fetchMembers:groupId completion:^(NSMutableArray *userIds)
	{
		[userIds removeObject:[FUser currentId]];
		SendPushNotification2(userIds, text);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification2(NSArray *userIds, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBUser *dbuser in [DBUser allObjects])
	{
		if ([userIds containsObject:dbuser.objectId])
		{
			if ([dbuser.oneSignalId length] != 0)
				[oneSignalIds addObject:dbuser.oneSignalId];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	//NSLog(@"%@ - %@", oneSignalIds, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal postNotification:@{@"contents":@{@"en":text}, @"include_player_ids":oneSignalIds}];
}

