//
// Copyright (c) 2016 Ryan
//

#import "PeopleCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PeopleCell()

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation PeopleCell

@synthesize imageUser, labelInitials, labelName;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(DBUser *)dbuser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelName.text = dbuser.fullname;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadImage:(DBUser *)dbuser TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *path = [DownloadManager pathImage:dbuser.picture];
	if (path == nil)
	{
		imageUser.image = [UIImage imageNamed:@"people_blank"];
		labelInitials.text = [dbuser initials];
		[self downloadImage:dbuser TableView:tableView IndexPath:indexPath];
	}
	else
	{
		imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
		labelInitials.text = nil;
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)downloadImage:(DBUser *)dbuser TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[DownloadManager image:dbuser.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if ((error == nil) && ([tableView.indexPathsForVisibleRows containsObject:indexPath]))
		{
			PeopleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			cell.labelInitials.text = nil;
		}
	}];
}

@end

