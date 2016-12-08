//
// Copyright (c) 2016 Ryan
//

#import "WelcomeView.h"
#import "LoginEmailView.h"
#import "RegisterEmailView.h"

@implementation WelcomeView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FUser signInWithFacebook:self completion:^(FUser *user, NSError *error)
	{
		if (error == nil)
		{
			if (user != nil)
			{
				[self dismissViewControllerAnimated:YES completion:^{
					UserLoggedIn(LOGIN_FACEBOOK);
				}];
			}
			else [ProgressHUD dismiss];
		}
		else [ProgressHUD showError:[error description]];
	}];
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

