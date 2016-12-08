//
// Copyright (c) 2016 Ryan
//

#import "Incoming.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Incoming()
{
	NSString *senderId;
	NSString *senderName;
	NSDate *date;

	BOOL wifi;
	BOOL maskOutgoing;

	DBMessage *dbmessage;
	JSQMessagesCollectionView *collectionView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Incoming

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(DBMessage *)dbmessage_ CollectionView:(JSQMessagesCollectionView *)collectionView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dbmessage = dbmessage_;
	collectionView = collectionView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	wifi = [Connection isReachableViaWiFi];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	senderId = dbmessage.senderId;
	senderName = dbmessage.senderName;
	date = [NSDate dateWithTimeIntervalSince1970:dbmessage.createdAt];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	maskOutgoing = [senderId isEqualToString:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_TEXT])		return [self createTextMessage];
	if ([dbmessage.type isEqualToString:MESSAGE_EMOJI])		return [self createEmojiMessage];
	if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])	return [self createPictureMessage];
	if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])		return [self createVideoMessage];
	if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])		return [self createAudioMessage];
	if ([dbmessage.type isEqualToString:MESSAGE_LOCATION])	return [self createLocationMessage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return nil;
}

#pragma mark - Text message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createTextMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = [Cryptor decryptText:dbmessage.text groupId:dbmessage.groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date text:text];
}

#pragma mark - Emoji message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createEmojiMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = [Cryptor decryptText:dbmessage.text groupId:dbmessage.groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	EmojiMediaItem *mediaItem = [[EmojiMediaItem alloc] initWithText:text];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Picture message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createPictureMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PhotoMediaItem *mediaItem = [[PhotoMediaItem alloc] initWithImage:nil Width:@(dbmessage.picture_width) Height:@(dbmessage.picture_height)];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[MediaManager loadPicture:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Video message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createVideoMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	VideoMediaItem *mediaItem = [[VideoMediaItem alloc] initWithMaskAsOutgoing:maskOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[MediaManager loadVideo:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Audio message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createAudioMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AudioMediaItem *mediaItem = [[AudioMediaItem alloc] initWithData:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[MediaManager loadAudio:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Location message

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createLocationMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc] initWithLocation:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CLLocation *location = [[CLLocation alloc] initWithLatitude:dbmessage.latitude longitude:dbmessage.longitude];
	[mediaItem setLocation:location withCompletionHandler:^{
		[collectionView reloadData];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

@end

