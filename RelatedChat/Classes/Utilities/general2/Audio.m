//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation Audio

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSNumber *)duration:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
	NSInteger duration = (NSInteger) round(CMTimeGetSeconds(asset.duration));
	return @(duration);
}

@end

