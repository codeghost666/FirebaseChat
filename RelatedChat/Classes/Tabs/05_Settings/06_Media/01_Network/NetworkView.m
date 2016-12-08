//
// Copyright (c) 2016 Ryan
//

#import "NetworkView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface NetworkView()
{
	NSInteger mediaType;
	NSInteger selectedNetwork;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cellManual;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellWiFi;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAll;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation NetworkView

@synthesize cellManual, cellWiFi, cellAll;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSInteger)mediaType_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	mediaType = mediaType_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (mediaType == MEDIA_IMAGE)	self.title = @"Image";
	if (mediaType == MEDIA_VIDEO)	self.title = @"Video";
	if (mediaType == MEDIA_AUDIO)	self.title = @"Audio";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self saveUser];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (mediaType == MEDIA_IMAGE)	selectedNetwork = [FUser networkImage];
	if (mediaType == MEDIA_VIDEO)	selectedNetwork = [FUser networkVideo];
	if (mediaType == MEDIA_AUDIO)	selectedNetwork = [FUser networkAudio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (mediaType == MEDIA_IMAGE)	user[FUSER_NETWORKIMAGE] = @(selectedNetwork);
	if (mediaType == MEDIA_VIDEO)	user[FUSER_NETWORKVIDEO] = @(selectedNetwork);
	if (mediaType == MEDIA_AUDIO)	user[FUSER_NETWORKAUDIO] = @(selectedNetwork);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[user saveInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
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
	return 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellManual;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellWiFi;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellAll;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) selectedNetwork = NETWORK_MANUAL;
	if ((indexPath.section == 0) && (indexPath.row == 1)) selectedNetwork = NETWORK_WIFI;
	if ((indexPath.section == 0) && (indexPath.row == 2)) selectedNetwork = NETWORK_ALL;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	cellManual.accessoryType = cellWiFi.accessoryType = cellAll.accessoryType = UITableViewCellAccessoryNone;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (selectedNetwork == NETWORK_MANUAL)	cellManual.accessoryType = UITableViewCellAccessoryCheckmark;
	if (selectedNetwork == NETWORK_WIFI)	cellWiFi.accessoryType = UITableViewCellAccessoryCheckmark;
	if (selectedNetwork == NETWORK_ALL)		cellAll.accessoryType = UITableViewCellAccessoryCheckmark;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

@end

