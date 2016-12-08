//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Recents()
{
	NSTimer *timer;
	BOOL refreshUserInterface;
	FIRDatabaseReference *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Recents

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (Recents *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static Recents *recents;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ recents = [[Recents alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return recents;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_APP_STARTED];
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refreshUserInterface) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FUser currentId] != nil)
	{
		if (firebase == nil) [self createObservers];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	firebase = [[FIRDatabase database] referenceWithPath:FRECENT_PATH];
	FIRDatabaseQuery *query = [[firebase queryOrderedByChild:FRECENT_USERID] queryEqualToValue:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *recent = snapshot.value;
		[Password set:recent[FRECENT_PASSWORD] groupId:recent[FRECENT_GROUPID]];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:recent];
			refreshUserInterface = YES;
		});
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *recent = snapshot.value;
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:recent];
			refreshUserInterface = YES;
		});
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateRealm:(NSDictionary *)recent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:recent];
	temp[FRECENT_MEMBERS] = [recent[FRECENT_MEMBERS] componentsJoinedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBRecent createOrUpdateInRealm:realm withValue:temp];
	[realm commitWriteTransaction];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase removeAllObservers]; firebase = nil;
}

#pragma mark - Notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshUserInterface
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (refreshUserInterface)
	{
		[NotificationCenter post:NOTIFICATION_REFRESH_RECENTS];
		refreshUserInterface = NO;
	}
}

@end

