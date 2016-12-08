//
// Copyright (c) 2016 Ryan
//

#import "AppConstant.h"

#import "EmojiMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface EmojiMediaItem()

@property (strong, nonatomic) UIImageView *cachedTextImageView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation EmojiMediaItem

#pragma mark - Initialization

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithText:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	if (self)
	{
		_text = [text copy];
		_cachedTextImageView = nil;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_text = nil;
	_cachedTextImageView = nil;
}

#pragma mark - Setters

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setText:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_text = [text copy];
	_cachedTextImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
	_cachedTextImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)mediaView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.text == nil)
	{
		return nil;
	}

	if (self.cachedTextImageView == nil)
	{
		CGSize size = [self mediaViewDisplaySize];
		BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;
		UIColor *colorBackground = outgoing ? COLOR_OUTGOING : COLOR_INCOMING;

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 50)];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:50];
		label.text = _text;

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
		imageView.backgroundColor = colorBackground;
		imageView.clipsToBounds = YES;
		[imageView addSubview:label];

		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
		self.cachedTextImageView = imageView;
	}

	return self.cachedTextImageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGSize)mediaViewDisplaySize
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return CGSizeMake(120, 70);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)mediaHash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return self.hash;
}

#pragma mark - NSObject

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (![super isEqual:object])
	{
		return NO;
	}

	EmojiMediaItem *emojiItem = (EmojiMediaItem *)object;
	return [self.text isEqualToString:emojiItem.text];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)hash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return super.hash ^ self.text.hash;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [NSString stringWithFormat:@"<%@: text=%@, appliesMediaViewMaskAsOutgoing=%@>",
			[self class], self.text, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)aCoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
}

#pragma mark - NSCopying

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone *)zone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	EmojiMediaItem *copy = [[[self class] allocWithZone:zone] initWithText:self.text];
	copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
	return copy;
}

@end

