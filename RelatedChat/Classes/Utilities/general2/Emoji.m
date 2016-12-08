//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation Emoji

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)isEmoji:(NSString *)string
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([string length] == 2)
	{
		const unichar high = [string characterAtIndex:0];

		if (0xd800 <= high && high <= 0xdbff)
		{
			const unichar low = [string characterAtIndex:1];
			const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
			
			return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
		}
		else return (0x2100 <= high && high <= 0x27bf);
	}
	return NO;
}

@end

