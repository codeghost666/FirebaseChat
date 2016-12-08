//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation Video

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIImage *)thumbnail:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	generator.appliesPreferredTrackTransform = YES;
	CMTime time = [asset duration]; time.value = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSError *error = nil;
	CMTime actualTime;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
	UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease(image);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return thumbnail;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSNumber *)duration:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
	NSInteger duration = (NSInteger) round(CMTimeGetSeconds(asset.duration));
	return @(duration);
}

@end

