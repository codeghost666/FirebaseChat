//
// Copyright (c) 2016 Ryan
//

#import "SettingsView.h"
#import "EditProfileView.h"
#import "PasswordView.h"
#import "StatusView.h"
#import "ArchiveView.h"
#import "CacheView.h"
#import "MediaView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "AddAccountView.h"
#import "SwitchAccountView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView()
{
	BOOL skipLoading;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellProfile;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellStatus;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellArchive;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAutoSave;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellAddAccount;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSwitchAccount;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogout;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogoutAll;

@property (strong, nonatomic) IBOutlet UISwitch *switchAutoSave;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, imageUser, labelInitials, labelName;
@synthesize cellProfile, cellPassword;
@synthesize cellStatus;
@synthesize cellArchive, cellCache, cellMedia, cellAutoSave;
@synthesize cellPrivacy, cellTerms;
@synthesize cellAddAccount, cellSwitchAccount;
@synthesize cellLogout, cellLogoutAll;
@synthesize switchAutoSave;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
		self.tabBarItem.title = @"Settings";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[NotificationCenter addObserver:self selector:@selector(loadUser) name:NOTIFICATION_USER_LOGGED_IN];
		[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[switchAutoSave addTarget:self action:@selector(actionAutoSaveSwitch) forControlEvents:UIControlEventValueChanged];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([FUser currentId] != nil)
	{
		if ([FUser isOnboardOk])
		{
			if (skipLoading)
				skipLoading = NO;
			else [self loadUser];
		}
		else OnboardUser(self);
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelInitials.text = [user initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:user[FUSER_PICTURE] completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			labelInitials.text = nil;
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = user[FUSER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellStatus.textLabel.text = user[FUSER_STATUS];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[switchAutoSave setOn:[user[FUSER_AUTOSAVEMEDIA] boolValue]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUserPictures:(NSDictionary *)links
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[FUSER_PICTURE] = links[@"linkPicture"];
	user[FUSER_THUMBNAIL] = links[@"linkThumbnail"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[user saveInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUserAutoSaveMedia:(BOOL)autoSaveMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	user[FUSER_AUTOSAVEMEDIA] = @(autoSaveMedia);
	[user saveInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	skipLoading = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Open camera" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { PresentPhotoCamera(self, YES); }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { PresentPhotoLibrary(self, YES); }];
	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionProfile
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	EditProfileView *editProfileView = [[EditProfileView alloc] initWith:NO];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:editProfileView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPassword
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PasswordView *passwordView = [[PasswordView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:passwordView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStatus
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StatusView *statusView = [[StatusView alloc] init];
	statusView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:statusView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionArchive
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ArchiveView *archiveView = [[ArchiveView alloc] init];
	archiveView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:archiveView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCache
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CacheView *cacheView = [[CacheView alloc] init];
	cacheView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:cacheView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MediaView *mediaView = [[MediaView alloc] init];
	mediaView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:mediaView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAutoSave
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ActionPremium();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAutoSaveSwitch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ActionPremium();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PrivacyView *privacyView = [[PrivacyView alloc] init];
	privacyView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:privacyView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTerms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	TermsView *termsView = [[TermsView alloc] init];
	termsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:termsView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAddAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ActionPremium();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ActionPremium();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleDestructive
													handler:^(UIAlertAction *action) { [self actionLogoutUser]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAll
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Log out all accounts" style:UIAlertActionStyleDestructive
													handler:^(UIAlertAction *action) { [self actionLogoutAllUser]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LogoutUser(DEL_ACCOUNT_ONE);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([Account count] == 0)
	{
		[self.tabBarController setSelectedIndex:DEFAULT_TAB];
	}
	else [self actionSwitchNextUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchNextUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *userIds = [Account userIds];
	NSString *userId = [userIds firstObject];
	NSDictionary *account = [Account account:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FUser signInWithEmail:account[@"email"] password:account[@"password"] completion:^(FUser *user, NSError *error)
	{
		if (error == nil)
		{
			UserLoggedIn(LOGIN_EMAIL);
		}
		else [ProgressHUD showError:[error description]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAllUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LogoutUser(DEL_ACCOUNT_ALL);
	[self.tabBarController setSelectedIndex:DEFAULT_TAB];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.image = [UIImage imageNamed:@"settings_blank"];
	labelName.text = nil;
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *imagePicture = [Image square:image size:140];
	UIImage *imageThumbnail = [Image square:image size:60];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
	NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRStorage *storage = [FIRStorage storage];
	FIRStorageReference *reference1 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_picture", @"jpg")];
	FIRStorageReference *reference2 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_thumbnail", @"jpg")];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference1 putData:dataPicture metadata:nil completion:^(FIRStorageMetadata *metadata1, NSError *error)
	{
		if (error == nil)
		{
			[reference2 putData:dataThumbnail metadata:nil completion:^(FIRStorageMetadata *metadata2, NSError *error)
			{
				if (error == nil)
				{
					labelInitials.text = nil;
					imageUser.image = imagePicture;
					NSString *linkPicture = metadata1.downloadURL.absoluteString;
					NSString *linkThumbnail = metadata2.downloadURL.absoluteString;
					[self saveUserPictures:@{@"linkPicture":linkPicture, @"linkThumbnail":linkThumbnail}];
				}
				else [ProgressHUD showError:@"Network error."];
			}];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 6;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BOOL emailLogin = [[FUser loginMethod] isEqualToString:LOGIN_EMAIL];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (section == 0) return emailLogin ? 2 : 1;
	if (section == 1) return 1;
	if (section == 2) return 4;
	if (section == 3) return 2;
	if (section == 4) return emailLogin ? 2 : 0;
	if (section == 5) return ([Account count] > 1) ? 2 : 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 1) return @"Status";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellProfile;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellPassword;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellStatus;
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellArchive;
	if ((indexPath.section == 2) && (indexPath.row == 1)) return cellCache;
	if ((indexPath.section == 2) && (indexPath.row == 2)) return cellMedia;
	if ((indexPath.section == 2) && (indexPath.row == 3)) return cellAutoSave;
	if ((indexPath.section == 3) && (indexPath.row == 0)) return cellPrivacy;
	if ((indexPath.section == 3) && (indexPath.row == 1)) return cellTerms;
	if ((indexPath.section == 4) && (indexPath.row == 0)) return cellAddAccount;
	if ((indexPath.section == 4) && (indexPath.row == 1)) return cellSwitchAccount;
	if ((indexPath.section == 5) && (indexPath.row == 0)) return cellLogout;
	if ((indexPath.section == 5) && (indexPath.row == 1)) return cellLogoutAll;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionProfile];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionPassword];
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionStatus];
	if ((indexPath.section == 2) && (indexPath.row == 0)) [self actionArchive];
	if ((indexPath.section == 2) && (indexPath.row == 1)) [self actionCache];
	if ((indexPath.section == 2) && (indexPath.row == 2)) [self actionMedia];
	if ((indexPath.section == 2) && (indexPath.row == 3)) [self actionAutoSave];
	if ((indexPath.section == 3) && (indexPath.row == 0)) [self actionPrivacy];
	if ((indexPath.section == 3) && (indexPath.row == 1)) [self actionTerms];
	if ((indexPath.section == 4) && (indexPath.row == 0)) [self actionAddAccount];
	if ((indexPath.section == 4) && (indexPath.row == 1)) [self actionSwitchAccount];
	if ((indexPath.section == 5) && (indexPath.row == 0)) [self actionLogout];
	if ((indexPath.section == 5) && (indexPath.row == 1)) [self actionLogoutAll];
}

@end

