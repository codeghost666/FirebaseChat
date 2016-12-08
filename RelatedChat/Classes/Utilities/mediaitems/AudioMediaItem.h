//
// Copyright (c) 2016 Ryan
//

#import "JSQMediaItem.h"
#import "JSQAudioMediaViewAttributes.h"

#import <AVFoundation/AVFoundation.h>

@class AudioMediaItem;

NS_ASSUME_NONNULL_BEGIN

//-------------------------------------------------------------------------------------------------------------------------------------------------
@protocol AudioMediaItemDelegate <NSObject>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)audioMediaItem:(AudioMediaItem *)audioMediaItem didChangeAudioCategory:(NSString *)category
			   options:(AVAudioSessionCategoryOptions)options error:(nullable NSError *)error;

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface AudioMediaItem : JSQMediaItem <JSQMessageMediaData, AVAudioPlayerDelegate, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, assign) int status;

@property (nonatomic, weak, nullable) id<AudioMediaItemDelegate> delegate;

@property (nonatomic, strong, readonly) JSQAudioMediaViewAttributes *audioViewAttributes;

@property (nonatomic, strong, nullable) NSData *audioData;

- (instancetype)initWithData:(nullable NSData *)audioData
         audioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes NS_DESIGNATED_INITIALIZER;

- (instancetype)init;

- (instancetype)initWithAudioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes;

- (instancetype)initWithData:(nullable NSData *)audioData;

- (void)setAudioDataWithUrl:(nonnull NSURL *)audioURL;

- (void)stopAudioPlayer;

@end

NS_ASSUME_NONNULL_END

