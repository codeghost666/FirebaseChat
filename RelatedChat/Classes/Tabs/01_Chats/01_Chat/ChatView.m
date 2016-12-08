//
// Copyright (c) 2016 Ryan
//

#import "ChatView.h"
#import "MapView.h"
#import "PictureView.h"
#import "VideoView.h"
#import "StickersView.h"
#import "ProfileView.h"
#import "MembersView.h"
#import "GroupDetailsView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSString *groupId;
	NSArray *members;
	NSString *description;
	NSString *type;

	FObject *group;

	NSInteger typingCounter;
	NSInteger insertCounter;

	Messages *messages;
	FIRDatabaseReference *firebase;

	RLMResults *dbmessages;
	NSMutableDictionary *jsqmessages;

	NSMutableArray *avatarIds;
	NSMutableDictionary *avatars;
	NSMutableDictionary *initials;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
}

@property (strong, nonatomic) IBOutlet UIView *viewTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDetails;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

@synthesize viewTitle, labelTitle, labelDetails;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSDictionary *)dictionary
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groupId = dictionary[@"groupId"];
	members = dictionary[@"members"];
	description = dictionary[@"description"];
	type = dictionary[@"type"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.titleView = viewTitle;
	[self updateTitleDetails];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_back"]
																	style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self
																			 action:@selector(actionDetails)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_CLEANUP_CHATVIEW];
	[NotificationCenter addObserver:self selector:@selector(refreshCollectionView1) name:NOTIFICATION_REFRESH_MESSAGES1];
	[NotificationCenter addObserver:self selector:@selector(refreshCollectionView2) name:NOTIFICATION_REFRESH_MESSAGES2];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	insertCounter = INSERT_MESSAGES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	jsqmessages = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	avatarIds = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
	initials = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQMessagesCollectionViewCell registerMenuAction:@selector(actionCopy:)];
	[JSQMessagesCollectionViewCell registerMenuAction:@selector(actionDelete:)];
	[JSQMessagesCollectionViewCell registerMenuAction:@selector(actionSave:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionCopy:)];
	UIMenuItem *menuItemDelete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionDelete:)];
	UIMenuItem *menuItemSave = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(actionSave:)];
	[UIMenuController sharedMenuController].menuItems = @[menuItemCopy, menuItemDelete, menuItemSave];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Recent clearCounter:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	messages = [[Messages alloc] initWith:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase = [[[FIRDatabase database] referenceWithPath:FTYPING_PATH] child:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadMessages];
	[self createTypingObservers];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	[self fetchGroup];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

#pragma mark - Custom menu actions for cells

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIMenuController *menu = [notification object];
	UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionCopy:)];
	UIMenuItem *menuItemDelete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionDelete:)];
	UIMenuItem *menuItemSave = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(actionSave:)];
	menu.menuItems = @[menuItemCopy, menuItemDelete, menuItemSave];
}

#pragma mark - Backend methods (message)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.automaticallyScrollsToMostRecentMessage = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@ AND isDeleted == NO", groupId];
	dbmessages = [[DBMessage objectsWithPredicate:predicate] sortedResultsUsingProperty:FMESSAGE_CREATEDAT ascending:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self refreshCollectionView2];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)insertMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	insertCounter += INSERT_MESSAGES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self refreshCollectionView2];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshCollectionView1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshCollectionView2];
	[self finishReceivingMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshCollectionView2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.showLoadEarlierMessagesHeader = (insertCounter < [dbmessages count]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.collectionView reloadData];
}

#pragma mark - Backend methods (avatar)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatar:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([avatarIds containsObject:userId]) return;
	else [avatarIds addObject:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", userId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbuser.thumbnail completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
			avatars[userId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30];
			[self performSelector:@selector(delayedReload) withObject:nil afterDelay:0.1];
		}
		else if (error.code != 100) [avatarIds removeObject:userId];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedReload
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.collectionView reloadData];
}

#pragma mark - Backend methods (group)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)fetchGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	object[FGROUP_OBJECTID] = groupId;
	[object fetchInBackground:^(NSError *error)
	{
		if (error == nil)
		{
			group = object;
			members = group[FGROUP_MEMBERS];
			description = group[FGROUP_NAME];
			[self updateTitleDetails];
		}
	}];
}

#pragma mark - Message sendig methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([Connection isReachable])
	{
		MessageSend1 *messageSend1 = [[MessageSend1 alloc] initWith:groupId View:self.navigationController.view];
		[messageSend1 send:text Video:video Picture:picture Audio:audio];
	}
	else
	{
		ActionPremium();
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQSystemSoundPlayer jsq_playMessageSentSound];
	[self finishSendingMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageDelete:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	[Message deleteItem:dbmessage];
}

#pragma mark - Typing indicator methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createTypingObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		if ([snapshot.key isEqualToString:[FUser currentId]] == NO)
		{
			BOOL typing = [snapshot.value boolValue];
			self.showTypingIndicator = typing;
			if (typing) [self scrollToBottomAnimated:YES];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter++;
	[self typingIndicatorSave:@YES];
	[self performSelector:@selector(typingIndicatorStop) withObject:nil afterDelay:2.0];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter--;
	if (typingCounter == 0) [self typingIndicatorSave:@NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorSave:(NSNumber *)typing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase updateChildValues:@{[FUser currentId]:typing}];
}

#pragma mark - UITextViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self typingIndicatorStart];
	return YES;
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId
		 senderDisplayName:(NSString *)name date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:text Video:nil Picture:nil Audio:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self actionAttach];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)senderId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [FUser currentId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)senderDisplayName
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [FUser fullname];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *messageId = dbmessage.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (jsqmessages[messageId] == nil)
	{
		Incoming *incoming = [[Incoming alloc] initWith:dbmessage CollectionView:self.collectionView];
		jsqmessages[messageId] = [incoming createMessage];
	}
	return jsqmessages[messageId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:indexPath])
	{
		return bubbleImageOutgoing;
	}
	else return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *senderId = dbmessage.senderId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (avatars[senderId] == nil)
	{
		[self loadAvatar:senderId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (initials[senderId] == nil)
	{
		initials[senderId] = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:dbmessage.senderInitials
								backgroundColor:HEXCOLOR(0xE4E4E4FF) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] diameter:30];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return (avatars[senderId] != nil) ? avatars[senderId] : initials[senderId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
	attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *jsqmessage = [self jsqmessage:indexPath];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:jsqmessage.date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
	attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self incoming:indexPath])
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		if (indexPath.item > 0)
		{
			DBMessage *dbprevious = [self dbmessage:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section]];
			if ([dbprevious.senderId isEqualToString:dbmessage.senderId])
			{
				return nil;
			}
		}
		return [[NSAttributedString alloc] initWithString:dbmessage.senderName];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:indexPath])
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		return [[NSAttributedString alloc] initWithString:dbmessage.status];
	}
	else return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return MIN(insertCounter, [dbmessages count]);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIColor *color = [self outgoing:indexPath] ? [UIColor whiteColor] : [UIColor blackColor];

	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	cell.textView.textColor = color;
	cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:color};

	return cell;
}

#pragma mark - UICollectionView Delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (action == @selector(actionCopy:))
	{
		if ([dbmessage.type isEqualToString:MESSAGE_TEXT]) return YES;
		if ([dbmessage.type isEqualToString:MESSAGE_EMOJI]) return YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (action == @selector(actionDelete:))
	{
		if ([self outgoing:indexPath]) return YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (action == @selector(actionSave:))
	{
		if ([dbmessage.type isEqualToString:MESSAGE_PICTURE]) return YES;
		if ([dbmessage.type isEqualToString:MESSAGE_VIDEO]) return YES;
		if ([dbmessage.type isEqualToString:MESSAGE_AUDIO]) return YES;
	}
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (action == @selector(actionCopy:))		[self actionCopy:indexPath];
	if (action == @selector(actionDelete:))		[self actionDelete:indexPath];
	if (action == @selector(actionSave:))		[self actionSave:indexPath];
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
	heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
	heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self incoming:indexPath])
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		if (indexPath.item > 0)
		{
			DBMessage *dbprevious = [self dbmessage:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section]];
			if ([dbprevious.senderId isEqualToString:dbmessage.senderId])
			{
				return 0;
			}
		}
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
	heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:indexPath])
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView
	didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self insertMessages];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *userId = dbmessage.senderId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([userId isEqualToString:[FUser currentId]] == NO)
	{
		ProfileView *profileView = [[ProfileView alloc] initWith:userId Chat:NO];
		[self.navigationController pushViewController:profileView animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	JSQMessage *jsqmessage = [self jsqmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])
	{
		PhotoMediaItem *mediaItem = (PhotoMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_MANUAL)
		{
			[MediaManager loadPictureManual:mediaItem dbmessage:dbmessage collectionView:collectionView];
			[collectionView reloadData];
		}
		if (mediaItem.status == STATUS_SUCCEED)
		{
			PictureView *pictureView = [[PictureView alloc] initWith:mediaItem.image];
			[self presentViewController:pictureView animated:YES completion:nil];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])
	{
		VideoMediaItem *mediaItem = (VideoMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_MANUAL)
		{
			[MediaManager loadVideoManual:mediaItem dbmessage:dbmessage collectionView:collectionView];
			[collectionView reloadData];
		}
		if (mediaItem.status == STATUS_SUCCEED)
		{
			VideoView *videoView = [[VideoView alloc] initWith:mediaItem.fileURL];
			[self presentViewController:videoView animated:YES completion:nil];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])
	{
		AudioMediaItem *mediaItem = (AudioMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_MANUAL)
		{
			[MediaManager loadAudioManual:mediaItem dbmessage:dbmessage collectionView:collectionView];
			[collectionView reloadData];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_LOCATION])
	{
		JSQLocationMediaItem *mediaItem = (JSQLocationMediaItem *)jsqmessage.media;
		MapView *mapView = [[MapView alloc] initWith:mediaItem.location];
		NavigationController *navController = [[NavigationController alloc] initWithRootViewController:mapView];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath
		 touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// This can be removed once JSQAudioMediaItem audioPlayer issue is fixed
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBMessage *dbmessage in dbmessages)
	{
		if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])
		{
			JSQMessage *jsqmessage = jsqmessages[dbmessage.objectId];
			AudioMediaItem *mediaItem = (AudioMediaItem *)jsqmessage.media;
			[mediaItem stopAudioPlayer];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self actionCleanup];
	[Recent clearCounter:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([type isEqualToString:CHAT_PRIVATE])
	{
		for (NSString *userId in members)
		{
			if ([userId isEqualToString:[FUser currentId]] == NO)
			{
				ProfileView *profileView = [[ProfileView alloc] initWith:userId Chat:NO];
				[self.navigationController pushViewController:profileView animated:YES];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:CHAT_MULTIPLE])
	{
		MembersView *membersView = [[MembersView alloc] initWith:members];
		[self.navigationController pushViewController:membersView animated:YES];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:CHAT_GROUP])
	{
		if (group != nil)
		{
			GroupDetailsView *groupDetailsView = [[GroupDetailsView alloc] initWith:groupId Chat:NO];
			[self.navigationController pushViewController:groupDetailsView animated:YES];
		}
		else [ProgressHUD showError:@"This group seems to be deleted."];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDelete:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageDelete:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCopy:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *text = [Cryptor decryptText:dbmessage.text groupId:groupId];
	[[UIPasteboard generalPasteboard] setString:text];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSave:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	JSQMessage *jsqmessage = [self jsqmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])
	{
		PhotoMediaItem *mediaItem = (PhotoMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_SUCCEED)
			UIImageWriteToSavedPhotosAlbum(mediaItem.image, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])
	{
		VideoMediaItem *mediaItem = (VideoMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_SUCCEED)
			UISaveVideoAtPathToSavedPhotosAlbum(mediaItem.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])
	{
		AudioMediaItem *mediaItem = (AudioMediaItem *)jsqmessage.media;
		if (mediaItem.status == STATUS_SUCCEED)
		{
			NSString *path = [File temp:@"mp4"];
			[mediaItem.audioData writeToFile:path atomically:NO];
			UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (error == nil)
	{
		[ProgressHUD showSuccess:@"Successfully saved."];
	}
	else [ProgressHUD showError:@"Save failed."];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAttach
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
	NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_picture"] title:@"Picture"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_video"] title:@"Video"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_sticker"] title:@"Sticker"]];
	RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
	gridMenu.delegate = self;
	[gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStickers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StickersView *stickersView = [[StickersView alloc] init];
	stickersView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:stickersView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - RNGridMenuDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[gridMenu dismissAnimated:NO];
	if ([item.title isEqualToString:@"Camera"])		PresentMultiCamera(self, YES);
	if ([item.title isEqualToString:@"Audio"])		PresentAudioRecorder(self);
	if ([item.title isEqualToString:@"Picture"])	PresentPhotoLibrary(self, YES);
	if ([item.title isEqualToString:@"Video"])		PresentVideoLibrary(self, YES);
	if ([item.title isEqualToString:@"Location"])	[self messageSend:nil Video:nil Picture:nil Audio:nil];
	if ([item.title isEqualToString:@"Sticker"])	[self actionStickers];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self messageSend:nil Video:video Picture:picture Audio:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IQAudioRecorderViewControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)audioRecorderController:(IQAudioRecorderViewController *)controller didFinishWithAudioAtPath:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:nil Video:nil Picture:nil Audio:path];
	[controller dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)audioRecorderControllerDidCancel:(IQAudioRecorderViewController *)controller
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - StickersDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSticker:(NSString *)sticker
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *picture = [UIImage imageNamed:sticker];
	[self messageSend:nil Video:nil Picture:picture Audio:nil];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[NotificationCenter removeObserver:self];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[messages actionCleanup]; messages = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase removeAllObservers]; firebase = nil;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTitleDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([type isEqualToString:CHAT_PRIVATE])
	{
		labelTitle.text = @"Private";
		labelDetails.text = description;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:CHAT_MULTIPLE])
	{
		labelTitle.text = @"Multiple";
		labelDetails.text = [NSString stringWithFormat:@"%ld members", (long) [members count]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:CHAT_GROUP])
	{
		labelTitle.text = description;
		labelDetails.text = [NSString stringWithFormat:@"%ld members", (long) [members count]];
	}
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)index:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger count = MIN(insertCounter, [dbmessages count]);
	NSInteger offset = [dbmessages count] - count;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return (indexPath.item + offset);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (DBMessage *)dbmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger index = [self index:indexPath];
	return dbmessages[index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)jsqmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	return jsqmessages[dbmessage.objectId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	return ([dbmessage.senderId isEqualToString:[FUser currentId]] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	return ([dbmessage.senderId isEqualToString:[FUser currentId]] == YES);
}

@end

