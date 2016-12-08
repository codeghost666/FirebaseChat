//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

@implementation Message

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateStatus:(NSString *)groupId messageId:(NSString *)messageId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FIRDatabaseReference *firebase = [[[[FIRDatabase database] referenceWithPath:FMESSAGE_PATH] child:groupId] child:messageId];
	[firebase updateChildValues:@{FMESSAGE_STATUS:TEXT_READ}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(NSString *)groupId messageId:(NSString *)messageId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FIRDatabaseReference *firebase = [[[[FIRDatabase database] referenceWithPath:FMESSAGE_PATH] child:groupId] child:messageId];
	[firebase updateChildValues:@{FMESSAGE_ISDELETED:@YES}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(DBMessage *)dbmessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([dbmessage.status isEqualToString:TEXT_QUEUED])
	{
		RLMRealm *realm = [RLMRealm defaultRealm];
		[realm beginWriteTransaction];
		[realm deleteObject:dbmessage];
		[realm commitWriteTransaction];
		[NotificationCenter post:NOTIFICATION_REFRESH_MESSAGES1];
	}
	else [self deleteItem:dbmessage.groupId messageId:dbmessage.objectId];
}

@end

