//
// Copyright (c) 2016 Ryan
//

#import "CallsView.h"
#import "CallView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallsView()
{
	NSString *callUserId;
	RLMResults *dbcallhistories;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CallsView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_calls"]];
		self.tabBarItem.title = @"Calls";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
		[NotificationCenter addObserver:self selector:@selector(refreshTableView) name:NOTIFICATION_REFRESH_CALLHISTORIES];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Calls";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadCallHistories];
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

		}
		else OnboardUser(self);
	}
	else LoginUser(self);
}

#pragma mark - Realm methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadCallHistories
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDeleted == NO AND type = %@", CALLHISTORY_AUDIO];
	dbcallhistories = [[DBCallHistory objectsWithPredicate:predicate] sortedResultsUsingProperty:FCALLHISTORY_CREATEDAT ascending:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self refreshTableView];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteCallHistory:(DBCallHistory *)dbcallhistory
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbcallhistory.isDeleted = YES;
	[realm commitWriteTransaction];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCallAudio
//-----------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCallVideo
//-----------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"actionCallVideo");
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView];
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
	return MIN([dbcallhistories count], 25);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBCallHistory *dbcallhistory = dbcallhistories[indexPath.row];
	cell.textLabel.text = dbcallhistory.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.detailTextLabel.text = dbcallhistory.status;
	cell.detailTextLabel.textColor = [UIColor grayColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dbcallhistory.startedAt];
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:date];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 50)];
	label.text = TimeElapsed(seconds);
	label.textAlignment = NSTextAlignmentRight;
	label.textColor = [UIColor grayColor];
	label.font = [UIFont systemFontOfSize:12];
	cell.accessoryView = label;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBCallHistory *dbcallhistory = dbcallhistories[indexPath.row];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self deleteCallHistory:dbcallhistory];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelector:@selector(deleteCallHistoryDelayed:) withObject:dbcallhistory afterDelay:0.25];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteCallHistoryDelayed:(DBCallHistory *)dbcallhistory
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[CallHistory deleteItem:dbcallhistory.objectId];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBCallHistory *dbcallhistory = dbcallhistories[indexPath.row];
	callUserId = [dbcallhistory.recipientId isEqualToString:[FUser currentId]] ? dbcallhistory.initiatorId : dbcallhistory.recipientId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbcallhistory.type isEqualToString:CALLHISTORY_AUDIO]) [self actionCallAudio];
	if ([dbcallhistory.type isEqualToString:CALLHISTORY_VIDEO]) [self actionCallVideo];
}

@end

