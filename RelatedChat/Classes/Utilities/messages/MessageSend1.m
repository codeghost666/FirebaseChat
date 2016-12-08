//
// Copyright (c) 2016 Ryan
//

#import "MessageSend1.h"
#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessageSend1()
{
	NSString *groupId;
	UIView *view;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessageSend1

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_ View:(UIView *)view_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	view = view_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH Subpath:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = groupId;
	message[FMESSAGE_SENDERID] = [FUser currentId];
	message[FMESSAGE_SENDERNAME] = [FUser fullname];
	message[FMESSAGE_SENDERINITIALS] = [FUser initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = @"";
	message[FMESSAGE_PICTURE_WIDTH] = @0;
	message[FMESSAGE_PICTURE_HEIGHT] = @0;
	message[FMESSAGE_PICTURE_MD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = @"";
	message[FMESSAGE_VIDEO_DURATION] = @0;
	message[FMESSAGE_VIDEO_MD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = @"";
	message[FMESSAGE_AUDIO_DURATION] = @0;
	message[FMESSAGE_AUDIO_MD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @0;
	message[FMESSAGE_LONGITUDE] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_STATUS] = TEXT_SENT;
	message[FMESSAGE_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (text != nil)	[self sendTextMessage:message Text:text];
	if (picture != nil)	[self sendPictureMessage:message Picture:picture];
	if (video != nil)	[self sendVideoMessage:message Video:video];
	if (audio != nil)	[self sendAudioMessage:message Audio:audio];
	if ((text == nil) && (picture == nil) && (video == nil) && (audio == nil)) [self sendLoactionMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendTextMessage:(FObject *)message Text:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TEXT] = text;
	message[FMESSAGE_TYPE] = [Emoji isEmoji:text] ? MESSAGE_EMOJI : MESSAGE_TEXT;
	[self sendMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendPictureMessage:(FObject *)message Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataPicture = UIImageJPEGRepresentation(picture, 0.6);
	NSData *cryptedPicture = [Cryptor encryptData:dataPicture groupId:groupId];
	NSString *md5Picture = [Checksum md5HashOfData:cryptedPicture];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRStorage *storage = [FIRStorage storage];
	FIRStorageReference *reference = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"message_image", @"jpg")];
	FIRStorageUploadTask *task = [reference putData:cryptedPicture metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error)
	{
		[hud hideAnimated:YES];
		[task removeAllObservers];
		if (error == nil)
		{
			NSString *link = metadata.downloadURL.absoluteString;
			NSString *file = [DownloadManager fileImage:link];
			[dataPicture writeToFile:[Dir document:file] atomically:NO];

			message[FMESSAGE_PICTURE] = link;
			message[FMESSAGE_PICTURE_WIDTH] = @((NSInteger) picture.size.width);
			message[FMESSAGE_PICTURE_HEIGHT] = @((NSInteger) picture.size.height);
			message[FMESSAGE_PICTURE_MD5] = md5Picture;
			message[FMESSAGE_TEXT] = @"[Picture message]";
			message[FMESSAGE_TYPE] = MESSAGE_PICTURE;
			[self sendMessage:message];
		}
		else [ProgressHUD showError:@"Message sending failed."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		hud.progress = (float) snapshot.progress.completedUnitCount / (float) snapshot.progress.totalUnitCount;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendVideoMessage:(FObject *)message Video:(NSURL *)video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSNumber *duration = [Video duration:video.path];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataVideo = [NSData dataWithContentsOfFile:video.path];
	NSData *cryptedVideo = [Cryptor encryptData:dataVideo groupId:groupId];
	NSString *md5Video = [Checksum md5HashOfData:cryptedVideo];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRStorage *storage = [FIRStorage storage];
	FIRStorageReference *reference = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"message_video", @"mp4")];
	FIRStorageUploadTask *task = [reference putData:cryptedVideo metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error)
	{
		[hud hideAnimated:YES];
		[task removeAllObservers];
		if (error == nil)
		{
			NSString *link = metadata.downloadURL.absoluteString;
			NSString *file = [DownloadManager fileVideo:link];
			[dataVideo writeToFile:[Dir document:file] atomically:NO];

			message[FMESSAGE_VIDEO] = link;
			message[FMESSAGE_VIDEO_DURATION] = duration;
			message[FMESSAGE_VIDEO_MD5] = md5Video;
			message[FMESSAGE_TEXT] = @"[Video message]";
			message[FMESSAGE_TYPE] = MESSAGE_VIDEO;
			[self sendMessage:message];
		}
		else [ProgressHUD showError:@"Message sending failed."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		hud.progress = (float) snapshot.progress.completedUnitCount / (float) snapshot.progress.totalUnitCount;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendAudioMessage:(FObject *)message Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSNumber *duration = [Audio duration:audio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataAudio = [NSData dataWithContentsOfFile:audio];
	NSData *cryptedAudio = [Cryptor encryptData:dataAudio groupId:groupId];
	NSString *md5Audio = [Checksum md5HashOfData:cryptedAudio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRStorage *storage = [FIRStorage storage];
	FIRStorageReference *reference = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"message_audio", @"m4a")];
	FIRStorageUploadTask *task = [reference putData:cryptedAudio metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error)
	{
		[hud hideAnimated:YES];
		[task removeAllObservers];
		if (error == nil)
		{
			NSString *link = metadata.downloadURL.absoluteString;
			NSString *file = [DownloadManager fileAudio:link];
			[dataAudio writeToFile:[Dir document:file] atomically:NO];

			message[FMESSAGE_AUDIO] = link;
			message[FMESSAGE_AUDIO_DURATION] = duration;
			message[FMESSAGE_AUDIO_MD5] = md5Audio;
			message[FMESSAGE_TEXT] = @"[Audio message]";
			message[FMESSAGE_TYPE] = MESSAGE_AUDIO;
			[self sendMessage:message];
		}
		else [ProgressHUD showError:@"Message sending failed."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		hud.progress = (float) snapshot.progress.completedUnitCount / (float) snapshot.progress.totalUnitCount;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendLoactionMessage:(FObject *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	message[FMESSAGE_LATITUDE] = @(app.coordinate.latitude);
	message[FMESSAGE_LONGITUDE] = @(app.coordinate.longitude);
	message[FMESSAGE_TEXT] = @"[Location message]";
	message[FMESSAGE_TYPE] = MESSAGE_LOCATION;
	[self sendMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(FObject *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TEXT] = [Cryptor encryptText:message[FMESSAGE_TEXT] groupId:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[message saveInBackground:^(NSError *error)
	{
		if (error == nil)
		{
			[Recent updateLastMessage:message];
			SendPushNotification1(message);
		}
		else [ProgressHUD showError:@"Message sending failed."];
	}];
}

@end

