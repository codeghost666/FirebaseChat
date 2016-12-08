//
// Copyright (c) 2016 Ryan
//

#import <UIKit/UIKit.h>

#import "AudioMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"

#import "DBMessage.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MediaManager : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Picture

+ (void)loadPicture:(PhotoMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage wifi:(BOOL)wifi
	 collectionView:(UICollectionView *)collectionView;

+ (void)loadPictureManual:(PhotoMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage
		   collectionView:(UICollectionView *)collectionView;

#pragma mark - Video

+ (void)loadVideo:(VideoMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage wifi:(BOOL)wifi
   collectionView:(UICollectionView *)collectionView;

+ (void)loadVideoManual:(VideoMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage
		 collectionView:(UICollectionView *)collectionView;

#pragma mark - Audio

+ (void)loadAudio:(AudioMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage wifi:(BOOL)wifi
   collectionView:(UICollectionView *)collectionView;

+ (void)loadAudioManual:(AudioMediaItem *)mediaItem dbmessage:(DBMessage *)dbmessage
		 collectionView:(UICollectionView *)collectionView;

@end

