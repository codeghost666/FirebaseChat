//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>
 
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Cryptor : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)encryptText:(NSString *)text groupId:(NSString *)groupId;
+ (NSString *)decryptText:(NSString *)text groupId:(NSString *)groupId;

+ (NSData *)encryptData:(NSData *)data groupId:(NSString *)groupId;
+ (NSData *)decryptData:(NSData *)data groupId:(NSString *)groupId;

+ (void)encryptFile:(NSString *)path groupId:(NSString *)groupId;
+ (void)decryptFile:(NSString *)path groupId:(NSString *)groupId;

@end

