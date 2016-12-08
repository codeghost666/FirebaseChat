//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"
 
@implementation Cryptor

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)encryptText:(NSString *)text groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataDecrypted = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSData *dataEncrypted = [self encryptData:dataDecrypted groupId:groupId];
	return [dataEncrypted base64EncodedStringWithOptions:0];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)decryptText:(NSString *)text groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataEncrypted = [[NSData alloc] initWithBase64EncodedString:text options:0];
	NSData *dataDecrypted = [self decryptData:dataEncrypted groupId:groupId];
	return [[NSString alloc] initWithData:dataDecrypted encoding:NSUTF8StringEncoding];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSData *)encryptData:(NSData *)data groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	NSString *password = [Password get:groupId];
	return [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSData *)decryptData:(NSData *)data groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	NSString *password = [Password get:groupId];
	return [RNDecryptor decryptData:data withPassword:password error:&error];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)encryptFile:(NSString *)path groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataDecrypted = [NSData dataWithContentsOfFile:path];
	NSData *dataEncrypted = [self encryptData:dataDecrypted groupId:groupId];
	[dataEncrypted writeToFile:path atomically:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)decryptFile:(NSString *)path groupId:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataEncrypted = [NSData dataWithContentsOfFile:path];
	NSData *dataDecrypted = [self decryptData:dataEncrypted groupId:groupId];
	[dataDecrypted writeToFile:path atomically:NO];
}

@end

