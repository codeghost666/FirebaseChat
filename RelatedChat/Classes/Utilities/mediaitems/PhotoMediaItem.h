//
// Copyright (c) 2016 Ryan
//

#import "JSQMediaItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PhotoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, assign) int status;

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;

- (instancetype)initWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height;

@end

