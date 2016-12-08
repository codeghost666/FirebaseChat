//
// Copyright (c) 2016 Ryan
//

#import "MediaView.h"
#import "NetworkView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MediaView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellImage;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellVideo;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAudio;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MediaView

@synthesize cellImage, cellVideo, cellAudio;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Media Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ActionPremium();
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self updateCell:[FUser networkImage] Cell:cellImage];
	[self updateCell:[FUser networkVideo] Cell:cellVideo];
	[self updateCell:[FUser networkAudio] Cell:cellAudio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateCell:(NSInteger)selectedNetwork Cell:(UITableViewCell *)cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (selectedNetwork == NETWORK_MANUAL)	cell.detailTextLabel.text = @"Manual";
	if (selectedNetwork == NETWORK_WIFI)	cell.detailTextLabel.text = @"Wi-Fi";
	if (selectedNetwork == NETWORK_ALL)		cell.detailTextLabel.text = @"Wi-Fi + Cellular";
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNetwork:(NSInteger)mediaType
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NetworkView *networkView = [[NetworkView alloc] initWith:mediaType];
	[self.navigationController pushViewController:networkView animated:YES];
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
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellImage;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellVideo;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellAudio;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionNetwork:MEDIA_IMAGE];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionNetwork:MEDIA_VIDEO];
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionNetwork:MEDIA_AUDIO];
}

@end

