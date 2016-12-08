//
// Copyright (c) 2016 Ryan
//

#import "JSQMediaItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface VideoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, assign) int status;

@property (nonatomic, strong) NSURL *fileURL;
@property (copy, nonatomic) UIImage *image;

- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end

