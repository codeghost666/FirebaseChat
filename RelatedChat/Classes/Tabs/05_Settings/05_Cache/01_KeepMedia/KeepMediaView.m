//
// Copyright (c) 2016 Ryan
//

#import "KeepMediaView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface KeepMediaView()
{
	NSInteger keepMedia;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cellWeek;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMonth;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForever;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation KeepMediaView

@synthesize cellWeek, cellMonth, cellForever;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"Keep Media";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	keepMedia = [FUser keepMedia];
	[self updateViewDetails];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	user[FUSER_KEEPMEDIA] = @(keepMedia);
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
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellWeek;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellMonth;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellForever;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) keepMedia = KEEPMEDIA_WEEK;
	if ((indexPath.section == 0) && (indexPath.row == 1)) keepMedia = KEEPMEDIA_MONTH;
	if ((indexPath.section == 0) && (indexPath.row == 2)) keepMedia = KEEPMEDIA_FOREVER;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self saveUser];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	cellWeek.accessoryType = cellMonth.accessoryType = cellForever.accessoryType = UITableViewCellAccessoryNone;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (keepMedia == KEEPMEDIA_WEEK)	cellWeek.accessoryType = UITableViewCellAccessoryCheckmark;
	if (keepMedia == KEEPMEDIA_MONTH)	cellMonth.accessoryType = UITableViewCellAccessoryCheckmark;
	if (keepMedia == KEEPMEDIA_FOREVER)	cellForever.accessoryType = UITableViewCellAccessoryCheckmark;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

@end

