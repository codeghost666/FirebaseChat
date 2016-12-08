//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface DownloadManager : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)image:(NSString *)link completion:(void (^)(NSString *path, NSError *error, BOOL network))completion;

+ (void)image:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion;
+ (void)video:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion;
+ (void)audio:(NSString *)link md5:(NSString *)md5 completion:(void (^)(NSString *path, NSError *error, BOOL network))completion;

+ (void)start:(NSString *)link ext:(NSString *)ext md5:(NSString *)md5 manual:(BOOL)checkManual
   completion:(void (^)(NSString *path, NSError *error, BOOL network))completion;

+ (NSString *)fileImage:(NSString *)link;
+ (NSString *)fileVideo:(NSString *)link;
+ (NSString *)fileAudio:(NSString *)link;

+ (NSString *)pathImage:(NSString *)link;
+ (NSString *)pathVideo:(NSString *)link;
+ (NSString *)pathAudio:(NSString *)link;

+ (void)clearManualImage:(NSString *)link;
+ (void)clearManualVideo:(NSString *)link;
+ (void)clearManualAudio:(NSString *)link;

@end

