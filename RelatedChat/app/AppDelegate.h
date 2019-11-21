//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

#import "ChatsView.h"
#import "CallsView.h"
#import "PeopleView.h"
#import "GroupsView.h"
#import "SettingsView.h"



//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface AppDelegate : UIResponder <UIApplicationDelegate, SINServiceDelegate, SINCallClientDelegate, CLLocationManagerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) ChatsView *chatsView;
@property (strong, nonatomic) CallsView *callsView;
@property (strong, nonatomic) PeopleView *peopleView;
@property (strong, nonatomic) GroupsView *groupsView;
@property (strong, nonatomic) SettingsView *settingsView;

@property (strong, nonatomic) id<SINService> sinchService;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

