//
// Copyright (c) 2016 Ryan
//

#import "ArchiveCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ArchiveCell()

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;

@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ArchiveCell

@synthesize imageUser, labelInitials;
@synthesize labelDescription, labelLastMessage;
@synthesize labelElapsed, labelCounter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(DBRecent *)dbrecent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelDescription.text = dbrecent.description;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *groupId = dbrecent.groupId;
	NSString *cryptedMessage = dbrecent.lastMessage;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
		NSString *lastMessage = [Cryptor decryptText:cryptedMessage groupId:groupId];
		dispatch_async(dispatch_get_main_queue(), ^{
			labelLastMessage.text = lastMessage;
		});
	});
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dbrecent.lastMessageDate];
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:date];
	labelElapsed.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelCounter.text = (dbrecent.counter != 0) ? [NSString stringWithFormat:@"%ld new", (long) dbrecent.counter] : nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadImage:(DBRecent *)dbrecent TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *path = [DownloadManager pathImage:dbrecent.picture];
	if (path == nil)
	{
		imageUser.image = [UIImage imageNamed:@"archive_blank"];
		labelInitials.text = dbrecent.initials;
		[self downloadImage:dbrecent TableView:tableView IndexPath:indexPath];
	}
	else
	{
		imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
		labelInitials.text = nil;
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)downloadImage:(DBRecent *)dbrecent TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[DownloadManager image:dbrecent.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if ((error == nil) && ([tableView.indexPathsForVisibleRows containsObject:indexPath]))
		{
			ArchiveCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			cell.labelInitials.text = nil;
		}
	}];
}

@end

