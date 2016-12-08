//
// Copyright (c) 2016 Ryan
//

#import "CacheView.h"
#import "KeepMediaView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CacheView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellKeepMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDescription;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellClearCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCacheSize;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CacheView

@synthesize cellKeepMedia, cellDescription;
@synthesize cellClearCache, cellCacheSize;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Cache Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails];
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
	NSInteger keepMedia = [FUser keepMedia];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (keepMedia == KEEPMEDIA_WEEK)	cellKeepMedia.detailTextLabel.text = @"1 week";
	if (keepMedia == KEEPMEDIA_MONTH)	cellKeepMedia.detailTextLabel.text = @"1 month";
	if (keepMedia == KEEPMEDIA_FOREVER)	cellKeepMedia.detailTextLabel.text = @"Forever";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionKeepMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	KeepMediaView *keepMediaView = [[KeepMediaView alloc] init];
	[self.navigationController pushViewController:keepMediaView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionClearCache
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[CacheManager cleanupManual];
	[self updateViewDetails];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	uint64_t total = [CacheManager total];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (total < 1000 * 1024)
		cellCacheSize.textLabel.text = [NSString stringWithFormat:@"Cache size: %llu Kbytes", total / 1024];
	else cellCacheSize.textLabel.text = [NSString stringWithFormat:@"Cache size: %llu Mbytes", total / (1000 * 1024)];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 2;
	if (section == 1) return 2;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 1)) return 160;
	return 50;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellKeepMedia;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellDescription;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellClearCache;
	if ((indexPath.section == 1) && (indexPath.row == 1)) return cellCacheSize;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionKeepMedia];
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionClearCache];
}

@end

