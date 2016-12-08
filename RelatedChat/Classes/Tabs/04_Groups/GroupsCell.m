//
// Copyright (c) 2016 Ryan
//

#import "GroupsCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsCell()

@property (strong, nonatomic) IBOutlet UIImageView *imageGroup;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelMembers;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupsCell

@synthesize imageGroup, labelName, labelMembers;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(DBGroup *)dbgroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelName.text = dbgroup.name;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = [dbgroup.members componentsSeparatedByString:@","];
	labelMembers.text = [NSString stringWithFormat:@"%ld members", (long) [members count]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadImage:(DBGroup *)dbgroup TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [DownloadManager pathImage:dbgroup.picture];
	if (path == nil)
	{
		imageGroup.image = [UIImage imageNamed:@"groups_blank"];
		[self downloadImage:dbgroup TableView:tableView IndexPath:indexPath];
	}
	else imageGroup.image = [[UIImage alloc] initWithContentsOfFile:path];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)downloadImage:(DBGroup *)dbgroup TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[DownloadManager image:dbgroup.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if ((error == nil) && ([tableView.indexPathsForVisibleRows containsObject:indexPath]))
		{
			GroupsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.imageGroup.image = [[UIImage alloc] initWithContentsOfFile:path];
		}
	}];
}

@end

