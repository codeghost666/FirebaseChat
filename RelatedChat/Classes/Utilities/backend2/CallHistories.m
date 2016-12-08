//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallHistories()
{
	NSTimer *timer;
	BOOL refreshUserInterface;
	FIRDatabaseReference *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CallHistories

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CallHistories *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static CallHistories *callHistories;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ callHistories = [[CallHistories alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return callHistories;
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
	firebase = [[[FIRDatabase database] referenceWithPath:FCALLHISTORY_PATH] child:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *callHistory = snapshot.value;
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:callHistory];
			refreshUserInterface = YES;
		});
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *callHistory = snapshot.value;
		dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
			[self updateRealm:callHistory];
			refreshUserInterface = YES;
		});
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateRealm:(NSDictionary *)callHistory
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBCallHistory createOrUpdateInRealm:realm withValue:callHistory];
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
		[NotificationCenter post:NOTIFICATION_REFRESH_CALLHISTORIES];
		refreshUserInterface = NO;
	}
}

@end

