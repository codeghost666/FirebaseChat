//
// Copyright (c) 2016 Ryan
//

#import "ProfileView.h"
#import "ChatView.h"
#import "CallView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProfileView()
{
	DBUser *dbuser;
	NSString *userId;
	BOOL isChatEnabled;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellCountry;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLocation;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellChat;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCall;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ProfileView

@synthesize viewHeader, imageUser, labelInitials, labelName, labelStatus;
@synthesize cellCountry, cellLocation, cellChat, cellCall;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)userId_ Chat:(BOOL)chat_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	userId = userId_;
	isChatEnabled = chat_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
}

#pragma mark - Realm methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", userId];
	dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelInitials.text = [dbuser initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbuser.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			labelInitials.text = nil;
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = dbuser.fullname;
	labelStatus.text = dbuser.status;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellCountry.detailTextLabel.text = dbuser.country;
	cellLocation.detailTextLabel.text = dbuser.location;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = StartPrivateChat(dbuser);
	ChatView *chatView = [[ChatView alloc] initWith:dictionary];
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCall
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ActionPremium();
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellCountry;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellLocation;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellChat;
	if ((indexPath.section == 1) && (indexPath.row == 1)) return cellCall;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 1) && (indexPath.row == 0))
	{
		if (isChatEnabled) [self actionChat]; else [self.navigationController popViewControllerAnimated:YES];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 1) && (indexPath.row == 1))
	{
		[self actionCall];
	}
}

@end

