//
// Copyright (c) 2016 Ryan
//

#import "AddAccountView.h"
#import "LoginEmailView.h"
#import "RegisterEmailView.h"

@implementation AddAccountView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Add Account";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginEmail:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginEmailView *loginEmailView = [[LoginEmailView alloc] init];
	loginEmailView.delegate = self;
	[self presentViewController:loginEmailView animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegisterEmail:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RegisterEmailView *registerEmailView = [[RegisterEmailView alloc] init];
	registerEmailView.delegate = self;
	[self presentViewController:registerEmailView animated:YES completion:nil];
}

#pragma mark - LoginEmailDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didLoginUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:^{
		UserLoggedIn(LOGIN_EMAIL);
	}];
}

#pragma mark - RegisterEmailDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didRegisterUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:^{
		UserLoggedIn(LOGIN_EMAIL);
	}];
}

@end

