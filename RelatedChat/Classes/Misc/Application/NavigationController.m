//
// Copyright (c) 2016 Ryan
//

#import "NavigationController.h"

@implementation NavigationController

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationBar.translucent = NO;
	self.navigationBar.barTintColor = HEXCOLOR(0x7FBB00FF);
	self.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIStatusBarStyleLightContent;
}

@end

