//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

#pragma mark - Private Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSDictionary* StartPrivateChat(DBUser *dbuser2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user1 = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *userId1 = [user1 objectId];
	NSString *userId2 = dbuser2.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *initials1 = [user1 initials];
	NSString *initials2 = [dbuser2 initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *picture1 = user1[FUSER_PICTURE];
	NSString *picture2 = dbuser2.picture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *name1 = user1[FUSER_FULLNAME];
	NSString *name2 = dbuser2.fullname;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = @[userId1, userId2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [members sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSString *groupId = [Checksum md5HashOfString:[sorted componentsJoinedByString:@""]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Password init:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Recent fetchMembers:groupId completion:^(NSMutableArray *userIds)
	{
		if ([userIds containsObject:userId1] == NO)
			[Recent createPrivate:userId1 groupId:groupId initials:initials2 picture:picture2 description:name2 members:members];
		if ([userIds containsObject:userId2] == NO)
			[Recent createPrivate:userId2 groupId:groupId initials:initials1 picture:picture1 description:name1 members:members];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return @{@"groupId":groupId, @"members":members, @"description":dbuser2.fullname, @"type":CHAT_PRIVATE};
}

#pragma mark - Multiple Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSDictionary* StartMultipleChat(NSArray *userIds)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *members = [NSMutableArray arrayWithArray:userIds];
	[members addObject:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [members sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSString *groupId = [Checksum md5HashOfString:[sorted componentsJoinedByString:@""]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Password init:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Recent createMultiple:groupId members:members];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return @{@"groupId":groupId, @"members":members, @"description":@"", @"type":CHAT_MULTIPLE};
}

#pragma mark - Group Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSDictionary* StartGroupChat(FObject *group)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSArray *members = group[FGROUP_MEMBERS];
	NSString *groupId = [group objectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *picture = (group[FGROUP_PICTURE] != nil) ? group[FGROUP_PICTURE] : [FUser picture];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Password init:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Recent createGroup:groupId picture:picture description:group[FGROUP_NAME] members:members];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return @{@"groupId":groupId, @"members":members, @"description":group[FGROUP_NAME], @"type":CHAT_GROUP};
}

#pragma mark - Restart Recent Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSDictionary* RestartRecentChat(DBRecent *dbrecent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSArray *members = [dbrecent.members componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return @{@"groupId":dbrecent.groupId, @"members":members, @"description":dbrecent.description, @"type":dbrecent.type};
}

