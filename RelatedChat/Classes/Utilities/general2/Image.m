//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation Image

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIImage *)square:(UIImage *)image size:(CGFloat)size
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *cropped;
	if (image.size.height > image.size.width)
	{
		CGFloat ypos = (image.size.height - image.size.width) / 2;
		cropped = [self crop:image x:0 y:ypos width:image.size.width height:image.size.width];
	}
	else
	{
		CGFloat xpos = (image.size.width - image.size.height) / 2;
		cropped = [self crop:image x:xpos y:0 width:image.size.height height:image.size.height];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [self resize:cropped width:size height:size scale:1];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIImage *)resize:(UIImage *)image width:(CGFloat)width height:(CGFloat)height scale:(CGFloat)scale
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = CGSizeMake(width, height);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIGraphicsBeginImageContextWithOptions(size, NO, scale);
	[image drawInRect:rect];
	UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return resized;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIImage *)crop:(UIImage *)image x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect rect = CGRectMake(x, y, width, height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cropped;
}

@end

