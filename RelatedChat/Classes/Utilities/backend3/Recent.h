//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Recent : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Fetch methods

+ (void)fetchRecents:(NSString *)groupId completion:(void (^)(NSMutableArray *recents))completion;
+ (void)fetchMembers:(NSString *)groupId completion:(void (^)(NSMutableArray *userIds))completion;

#pragma mark - Create methods

+ (void)createPrivate:(NSString *)userId groupId:(NSString *)groupId initials:(NSString *)initials picture:(NSString *)picture
		  description:(NSString *)description members:(NSArray *)members;

+ (void)createMultiple:(NSString *)groupId members:(NSArray *)members;

+ (void)createGroup:(NSString *)groupId picture:(NSString *)picture description:(NSString *)description members:(NSArray *)members;

+ (void)createItem:(NSString *)userId groupId:(NSString *)groupId initials:(NSString *)initials picture:(NSString *)picture
	   description:(NSString *)description members:(NSArray *)members type:(NSString *)type;

#pragma mark - Update methods

+ (void)updateLastMessage:(FObject *)message;

+ (void)updateMembers:(FObject *)group;
+ (void)updateDescription:(FObject *)group;
+ (void)updatePicture:(FObject *)group;

#pragma mark - Delete/Archive methods

+ (void)deleteItem:(NSString *)objectId;
+ (void)archiveItem:(NSString *)objectId;
+ (void)unarchiveItem:(NSString *)objectId;

#pragma mark - Clear methods

+ (void)clearCounter:(NSString *)groupId;

@end

