//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation File

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)temp:(NSString *)ext
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int interval = (int) [[NSDate date] timeIntervalSince1970];
	NSString *file = [NSString stringWithFormat:@"%d.%@", interval, ext];
	return [Dir cache:file];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)exist:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)remove:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)copy:(NSString *)src dest:(NSString *)dest overwrite:(BOOL)overwrite
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (overwrite) [self remove:dest];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self exist:dest] == NO) [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDate *)created:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return attributes[NSFileCreationDate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDate *)modified:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return attributes[NSFileModificationDate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (uint64_t)size:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return [attributes[NSFileSize] unsignedLongLongValue];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (uint64_t)diskFree
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:nil];
	return [attributes[NSFileSystemFreeSize] unsignedLongLongValue];
}

@end

