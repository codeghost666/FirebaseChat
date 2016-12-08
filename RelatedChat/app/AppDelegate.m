//
// Copyright (c) 2016 Ryan
//

#import "AppDelegate.h"
#import "CallView.h"
#import "ChatsView.h"
#import "CallsView.h"
#import "PeopleView.h"
#import "GroupsView.h"
#import "SettingsView.h"
#import "NavigationController.h"

@implementation AppDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Crashlytics initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Fabric with:@[[Crashlytics class]]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Firebase initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FIRApp configure];
	[FIRDatabase database].persistenceEnabled = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Facebook login initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Push notification initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
	{
		UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
		[center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
		completionHandler:^(BOOL granted, NSError *error)
		{
			if (error == nil) [[UIApplication sharedApplication] registerForRemoteNotifications];
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
	{
		if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
		{
			UIUserNotificationType userNotificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
			UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
			[application registerUserNotificationSettings:settings];
			[application registerForRemoteNotifications];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// OneSignal initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APPID handleNotificationReceived:nil handleNotificationAction:nil
							settings:@{kOSSettingsKeyInAppAlerts:@NO}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal setLogLevel:ONE_S_LL_NONE visualLevel:ONE_S_LL_NONE];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// This can be removed once Firebase auth issue is resolved
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UserDefaults boolForKey:@"Initialized"] == NO)
	{
		[UserDefaults setObject:@YES forKey:@"Initialized"];
		[FUser logOut];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Reachability initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Connection shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Realm initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[CallHistories shared];
	[Groups shared];
	[Recents shared];
	[Users shared];
	[UserStatuses shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// UI initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.chatsView = [[ChatsView alloc] initWithNibName:@"ChatsView" bundle:nil];
	self.callsView = [[CallsView alloc] initWithNibName:@"CallsView" bundle:nil];
	self.peopleView = [[PeopleView alloc] initWithNibName:@"PeopleView" bundle:nil];
	self.groupsView = [[GroupsView alloc] initWithNibName:@"GroupsView" bundle:nil];
	self.settingsView = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];

	NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.chatsView];
	NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.callsView];
	NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
	NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
	NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.settingsView];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4, navController5];
	self.tabBarController.tabBar.translucent = NO;
	self.tabBarController.selectedIndex = DEFAULT_TAB;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.chatsView view];
	[self.callsView view];
	[self.peopleView view];
	[self.groupsView view];
	[self.settingsView view];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self locationManagerStop];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[FBSDKAppEvents activateApp];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal IdsAvailable:^(NSString *userId, NSString *pushToken)
	{
		if (pushToken != nil)
			[UserDefaults setObject:userId forKey:@"OneSignalId"];
		else [UserDefaults removeObjectForKey:@"OneSignalId"];
		UpdateOneSignalId();
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[CacheManager cleanupExpired];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter post:NOTIFICATION_APP_STARTED];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self locationManagerStart];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - Facebook responses

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url
												sourceApplication:sourceApplication annotation:annotation];
}


#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - Location manager methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.locationManager == nil)
	{
		self.locationManager = [[CLLocationManager alloc] init];
		[self.locationManager setDelegate:self];
		[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[self.locationManager requestWhenInUseAuthorization];
	}
	[self.locationManager startUpdatingLocation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.coordinate = newLocation.coordinate;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initUserStatuses
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self initUserStatus:@"Available"];
	[self initUserStatus:@"Busy"];
	[self initUserStatus:@"At school"];
	[self initUserStatus:@"At the movies"];
	[self initUserStatus:@"At work"];
	[self initUserStatus:@"Battery about to die"];
	[self initUserStatus:@"Can't talk now"];
	[self initUserStatus:@"In a meeting"];
	[self initUserStatus:@"At the gym"];
	[self initUserStatus:@"Sleeping"];
	[self initUserStatus:@"Urgent calls only"];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initUserStatus:(NSString *)name
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FUSERSTATUS_PATH];
	object[FUSERSTATUS_NAME] = name;
	[object saveInBackground:^(NSError *error)
	{
		if (error != nil) NSLog(@"initUserStatus error: %@", error);
	}];
}

@end

