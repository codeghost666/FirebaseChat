//
// Copyright (c) 2016 Ryan
//

#import "EditProfileView.h"
#import "CountriesView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface EditProfileView()
{
	BOOL isOnboard;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellFirstname;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLastname;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCountry;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLocation;

@property (strong, nonatomic) IBOutlet UITextField *fieldFirstname;
@property (strong, nonatomic) IBOutlet UITextField *fieldLastname;

@property (strong, nonatomic) IBOutlet UILabel *labelPlaceholder;
@property (strong, nonatomic) IBOutlet UILabel *labelCountry;
@property (strong, nonatomic) IBOutlet UITextField *fieldLocation;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation EditProfileView

@synthesize viewHeader, imageUser, labelInitials;
@synthesize cellFirstname, cellLastname, cellCountry, cellLocation;
@synthesize fieldFirstname, fieldLastname;
@synthesize labelPlaceholder, labelCountry, fieldLocation;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(BOOL)isOnboard_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	isOnboard = isOnboard_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Edit Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
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
	fieldFirstname.text = user[FUSER_FIRSTNAME];
	fieldLastname.text = user[FUSER_LASTNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelCountry.text = user[FUSER_COUNTRY];
	fieldLocation.text = user[FUSER_LOCATION];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *fullname = [NSString stringWithFormat:@"%@ %@", fieldFirstname.text, fieldLastname.text];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[FUSER_FULLNAME] = fullname;
	user[FUSER_FIRSTNAME] = fieldFirstname.text;
	user[FUSER_LASTNAME] = fieldLastname.text;
	user[FUSER_COUNTRY] = labelCountry.text;
	user[FUSER_LOCATION] = fieldLocation.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[user saveInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
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

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isOnboard) LogoutUser(DEL_ACCOUNT_ALL);
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([fieldFirstname.text length] == 0)	{	[ProgressHUD showError:@"Firstname must be set."];	return; }
	if ([fieldLastname.text length] == 0)	{	[ProgressHUD showError:@"Lastname must be set."];	return; }
	if ([labelCountry.text length] == 0)	{	[ProgressHUD showError:@"Country must be set."];	return; }
	if ([fieldLocation.text length] == 0)	{	[ProgressHUD showError:@"Location must be set."];	return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self saveUser];
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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
- (void)actionCountries
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CountriesView *countriesView = [[CountriesView alloc] init];
	countriesView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:countriesView];
	[self presentViewController:navController animated:YES completion:nil];
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

#pragma mark - CountriesDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectCountry:(NSString *)country CountryCode:(NSString *)countryCode
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelCountry.text = country;
	[fieldLocation becomeFirstResponder];
	[self updateViewDetails];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellFirstname;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellLastname;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellCountry;
	if ((indexPath.section == 0) && (indexPath.row == 3)) return cellLocation;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionCountries];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldFirstname)	[fieldLastname becomeFirstResponder];
	if (textField == fieldLastname)		[self actionCountries];
	if (textField == fieldLocation)		[self actionDone];
	return YES;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelPlaceholder.hidden = (labelCountry.text != nil);
}

@end

