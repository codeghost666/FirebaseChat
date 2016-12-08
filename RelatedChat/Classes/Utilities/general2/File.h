//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>
 
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface File : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)temp:(NSString *)ext;

+ (BOOL)exist:(NSString *)path;

+ (BOOL)remove:(NSString *)path;

+ (void)copy:(NSString *)src dest:(NSString *)dest overwrite:(BOOL)overwrite;

+ (NSDate *)created:(NSString *)path;

+ (NSDate *)modified:(NSString *)path;

+ (uint64_t)size:(NSString *)path;

+ (uint64_t)diskFree;

@end

