//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface NSError (Util)
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (NSError *)description:(NSString *)description code:(NSInteger)code;

- (NSString *)description;

@end

