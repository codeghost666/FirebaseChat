//
// Copyright (c) 2016 Ryan
//

#import "ChatsView.h"
#import "ChatsCell.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatsView()
{
	RLMResults *dbrecents;
	SWTableViewCell *lastCell;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatsView

@synthesize searchBar;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_chats"]];
		self.tabBarItem.title = @"Chats";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
		[NotificationCenter addObserver:self selector:@selector(refreshTableView) name:NOTIFICATION_REFRESH_RECENTS];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chats";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
																						   action:@selector(actionCompose)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"ChatsCell" bundle:nil] forCellReuseIdentifier:@"ChatsCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadRecents];
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
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = searchBar.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO AND isDeleted == NO AND description CONTAINS[c] %@", text];
	dbrecents = [[DBRecent objectsWithPredicate:predicate] sortedResultsUsingProperty:FRECENT_LASTMESSAGEDATE ascending:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self refreshTableView];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)archiveRecent:(DBRecent *)dbrecent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbrecent.isArchived = YES;
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteRecent:(DBRecent *)dbrecent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbrecent.isDeleted = YES;
	[realm commitWriteTransaction];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
	[self refreshTabCounter];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger total = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBRecent *dbrecent in dbrecents)
		total += dbrecent.counter;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITabBarItem *item = self.tabBarController.tabBar.items[0];
	item.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
	if (currentUserNotificationSettings.types & UIUserNotificationTypeBadge)
		[UIApplication sharedApplication].applicationIconBadgeNumber = total;
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSDictionary *)dictionary
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:dictionary];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Single recipient" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionSelectSingle]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Multiple recipients" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionSelectMultiple]; }];
	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectSingle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
	selectSingleView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectMultiple
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
	selectMultipleView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionArchive:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBRecent *dbrecent = dbrecents[index];
	NSString *recentId = dbrecent.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self archiveRecent:dbrecent];
	[self refreshTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelector:@selector(delayedArchive:) withObject:recentId afterDelay:0.25];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedArchive:(NSString *)recentId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
	[Recent archiveItem:recentId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDelete:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBRecent *dbrecent = dbrecents[index];
	NSString *recentId = dbrecent.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self deleteRecent:dbrecent];
	[self refreshTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelector:@selector(delayedDelete:) withObject:recentId afterDelay:0.25];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedDelete:(NSString *)recentId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
	[Recent deleteItem:recentId];
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(DBUser *)dbuser2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = StartPrivateChat(dbuser2);
	[self actionChat:dictionary];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSArray *)userIds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = StartMultipleChat(userIds);
	[self actionChat:dictionary];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView];
}

#pragma mark - UIScrollViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
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
	return [dbrecents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsCell" forIndexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.leftUtilityButtons = nil;
	cell.rightUtilityButtons = [self rightButtons];
	cell.delegate = self;
	cell.tag = indexPath.row;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[cell bindData:dbrecents[indexPath.row]];
	[cell loadImage:dbrecents[indexPath.row] TableView:tableView IndexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)rightButtons
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
	[rightUtilityButtons sw_addUtilityButtonWithColor:HEXCOLOR(0x3E70A7FF) title:@"Archive"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"Delete"];
	return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[cell hideUtilityButtonsAnimated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (index == 0) [self actionArchive:cell.tag];
	if (index == 1) [self actionDelete:cell.tag];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (state == kCellStateRight) lastCell = cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((lastCell == nil) || [lastCell isUtilityButtonsHidden])
	{
		DBRecent *dbrecent = dbrecents[indexPath.row];
		NSDictionary *dictionary = RestartRecentChat(dbrecent);
		[self actionChat:dictionary];
	}
	else [lastCell hideUtilityButtonsAnimated:YES];
}

#pragma mark - UISearchBarDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self loadRecents];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar setShowsCancelButton:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	[self loadRecents];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar resignFirstResponder];
}

@end

