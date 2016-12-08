//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

@implementation DownloadManager

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)image:(NSString *)link completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self start:link ext:@"jpg" md5:nil manual:NO completion:completion];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)image:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self start:link ext:@"jpg" md5:md5 manual:YES completion:completion];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)video:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self start:link ext:@"mp4" md5:md5 manual:YES completion:completion];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)audio:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self start:link ext:@"m4a" md5:md5 manual:YES completion:completion];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)start:(NSString *)link ext:(NSString *)ext md5:(NSString *)md5 manual:(BOOL)checkManual
   completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if link is missing
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([link length] == 0) { if (completion != nil) completion(nil, [NSError description:@"Missing link." code:100], NO); return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *file = [self file:link ext:ext];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *path = [Dir document:file];
	NSString *manual = [Dir document:[file stringByAppendingString:@".manual"]];
	NSString *loading = [Dir document:[file stringByAppendingString:@".loading"]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if file is already downloaded
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([File exist:path]) { if (completion != nil) completion(path, nil, NO); return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if manual download is required
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (checkManual)
	{
		if ([File exist:manual]) { if (completion != nil) completion(nil, [NSError description:@"Manual download required." code:101], NO); return; }
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[@"manual" writeToFile:manual atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if file is currently downloading
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int time = (int) [[NSDate date] timeIntervalSince1970];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([File exist:loading])
	{
		int check = [[NSString stringWithContentsOfFile:loading encoding:NSUTF8StringEncoding error:nil] intValue];
		if (time - check < DOWNLOAD_TIMEOUT) return;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSString stringWithFormat:@"%d", time] writeToFile:loading atomically:NO encoding:NSUTF8StringEncoding error:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Download the file
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:link]
	completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
	{
		if (error == nil)
		{
			[[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
			//-------------------------------------------------------------------------------------------------------------------------------------
			if ([File size:path] != 0)
			{
				if (md5 != nil)
				{
					if ([md5 isEqualToString:[Checksum md5HashOfPath:path]])
					{
						[self succeed:file completion:completion];
					}
					else [self failed:file error:[NSError description:@"MD5 checksum." code:102] completion:completion];
				}
				else [self succeed:file completion:completion];
			}
			else [self failed:file error:[NSError description:@"Zero lenght." code:103] completion:completion];
		}
		else [self failed:file error:error completion:completion];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[downloadTask resume];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)succeed:(NSString *)file
	 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [Dir document:file];
	NSString *loading = [Dir document:[file stringByAppendingString:@".loading"]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[File remove:loading];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_async(dispatch_get_main_queue(), ^{
		if (completion != nil) completion(path, nil, YES);
	});
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)failed:(NSString *)file error:(NSError *)error
	completion:(void (^)(NSString *path, NSError *error, BOOL network))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [Dir document:file];
	NSString *loading = [Dir document:[file stringByAppendingString:@".loading"]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[File remove:path];
	[File remove:loading];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_async(dispatch_get_main_queue(), ^{
		if (completion != nil) completion(nil, error, YES);
	});
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)fileImage:(NSString *)link	{	return [self file:link ext:@"jpg"];		}
+ (NSString *)fileVideo:(NSString *)link	{	return [self file:link ext:@"mp4"];		}
+ (NSString *)fileAudio:(NSString *)link	{	return [self file:link ext:@"m4a"];		}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)file:(NSString *)link ext:(NSString *)ext
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *file = [Checksum md5HashOfString:link];
	return [file stringByAppendingPathExtension:ext];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)pathImage:(NSString *)link	{	return [self path:link ext:@"jpg"];		}
+ (NSString *)pathVideo:(NSString *)link	{	return [self path:link ext:@"mp4"];		}
+ (NSString *)pathAudio:(NSString *)link	{	return [self path:link ext:@"m4a"];		}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)path:(NSString *)link ext:ext
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([link length] != 0)
	{
		NSString *file = [self file:link ext:ext];
		NSString *path = [Dir document:file];
		if ([File exist:path]) return path;
	}
	return nil;
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)clearManualImage:(NSString *)link	{	[self clearManual:link ext:@"jpg"];		}
+ (void)clearManualVideo:(NSString *)link	{	[self clearManual:link ext:@"mp4"];		}
+ (void)clearManualAudio:(NSString *)link	{	[self clearManual:link ext:@"m4a"];		}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)clearManual:(NSString *)link ext:(NSString *)ext
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *file = [self file:link ext:ext];
	NSString *manual = [Dir document:[file stringByAppendingString:@".manual"]];
	[File remove:manual];
}

@end

