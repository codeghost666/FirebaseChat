//
// Copyright (c) 2016 Ryan
//

#import "StatusView.h"
#import "CustomStatusView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface StatusView()
{
	RLMResults *dbuserstatuses;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cellStatus;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellClear;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation StatusView

@synthesize cellStatus, cellClear;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Status";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadStatuses];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	[self loadUser];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadStatuses
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	dbuserstatuses = [[DBUserStatus allObjects] sortedResultsUsingProperty:FUSERSTATUS_CREATEDAT ascending:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	cellStatus.textLabel.text = [FUser status];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	cellStatus.textLabel.text = status;
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FUser *user = [FUser currentUser];
	user[FUSER_STATUS] = status;
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
	return ([dbuserstatuses count] == 0) ? 1 : 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 1;
	if (section == 1) return [dbuserstatuses count];
	if (section == 2) return 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return @"Your current status is";
	if (section == 1) return @"Select your new status";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellStatus;
	if (indexPath.section == 1)
	{
		return [self tableView:tableView cellForRowAtIndexPath1:indexPath];
	}
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellClear;
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath1:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBUserStatus *dbuserstatus = dbuserstatuses[indexPath.row];
	cell.textLabel.text = dbuserstatus.name;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 0)
	{
		CustomStatusView *customStatusView = [[CustomStatusView alloc] init];
		NavigationController *navController = [[NavigationController alloc] initWithRootViewController:customStatusView];
		[self presentViewController:navController animated:YES completion:nil];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 1)
	{
		DBUserStatus *dbuserstatus = dbuserstatuses[indexPath.row];
		[self saveUser:dbuserstatus.name];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 2)
	{
		[self saveUser:@""];
	}
}

@end

