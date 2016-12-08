//
// Copyright (c) 2016 Ryan
//

#import "NSError+Util.h"

@implementation NSError (Util)

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSError *)description:(NSString *)description code:(NSInteger)code
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *domain = [[NSBundle mainBundle] bundleIdentifier];
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey:description};
	return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return self.userInfo[NSLocalizedDescriptionKey];
}

@end

