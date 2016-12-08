//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Groups()
{
	NSTimer *timer;
	BOOL refreshUserInterface;
	FIRDatabaseReference *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Groups

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (Groups *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static Groups *groups;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ groups = [[Groups alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groups;
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
	firebase = [[FIRDatabase database] referenceWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *group = snapshot.value;
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:group];
			refreshUserInterface = YES;
		});
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *group = snapshot.value;
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:group];
			refreshUserInterface = YES;
		});
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateRealm:(NSDictionary *)group
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:group];
	temp[FGROUP_MEMBERS] = [group[FGROUP_MEMBERS] componentsJoinedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBGroup createOrUpdateInRealm:realm withValue:temp];
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
		[NotificationCenter post:NOTIFICATION_REFRESH_GROUPS];
		refreshUserInterface = NO;
	}
}

@end

