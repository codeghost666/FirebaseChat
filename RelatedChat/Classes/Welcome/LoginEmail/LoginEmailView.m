//
// Copyright (c) 2016 Ryan
//

#import "LoginEmailView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoginEmailView()

@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation LoginEmailView

@synthesize delegate;
@synthesize fieldEmail, fieldPassword;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.view addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *email = [fieldEmail.text lowercaseString];
	NSString *password = fieldPassword.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([email length] == 0)	{ [ProgressHUD showError:@"Please enter your email."]; return; }
	if ([password length] == 0)	{ [ProgressHUD showError:@"Please enter your password."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	LogoutUser(DEL_ACCOUNT_NONE);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FUser signInWithEmail:email password:password completion:^(FUser *user, NSError *error)
	{
		if (error == nil)
		{
			[Account add:email password:password];
			[self dismissViewControllerAnimated:YES completion:^{
				if (delegate != nil) [delegate didLoginUser];
			}];
		}
		else [ProgressHUD showError:[error description]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionDismiss:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldEmail) [fieldPassword becomeFirstResponder];
	if (textField == fieldPassword) [self actionLogin:nil];
	return YES;
}

@end

