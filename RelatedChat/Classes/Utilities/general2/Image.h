//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>
 
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Image : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (UIImage *)square:(UIImage *)image size:(CGFloat)size;

+ (UIImage *)resize:(UIImage *)image width:(CGFloat)width height:(CGFloat)height scale:(CGFloat)scale;

@end

