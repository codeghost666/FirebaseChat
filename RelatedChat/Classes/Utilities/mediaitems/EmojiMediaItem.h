//
// Copyright (c) 2016 Ryan
//

#import "JSQMediaItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface EmojiMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, strong) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

