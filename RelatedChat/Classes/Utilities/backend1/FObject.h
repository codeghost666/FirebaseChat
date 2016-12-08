//
// Copyright (c) 2016 Ryan
//

#import <Firebase/Firebase.h>

NS_ASSUME_NONNULL_BEGIN

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FObject : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Properties

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *subpath;

@property (nonatomic, strong) NSMutableDictionary *dictionary;

#pragma mark - Class methods

+ (instancetype)objectWithPath:(NSString *)path;
+ (instancetype)objectWithPath:(NSString *)path dictionary:(NSDictionary *)dictionary;

+ (instancetype)objectWithPath:(NSString *)path Subpath:(NSString *)subpath;
+ (instancetype)objectWithPath:(NSString *)path Subpath:(NSString *)subpath dictionary:(NSDictionary *)dictionary;

#pragma mark - Instance methods

- (instancetype)initWithPath:(NSString *)path_;
- (instancetype)initWithPath:(NSString *)path_ dictionary:(NSDictionary *)dictionary_;

- (instancetype)initWithPath:(NSString *)path_ Subpath:(nullable NSString *)subpath_;
- (instancetype)initWithPath:(NSString *)path_ Subpath:(nullable NSString *)subpath_ dictionary:(NSDictionary *)dictionary_;

#pragma mark - Accessors

- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

- (NSString *)objectId;
- (NSString *)objectIdInit;

#pragma mark - Save methods

- (void)saveInBackground;
- (void)saveInBackground:(nullable void (^)(NSError * _Nullable error))block;

#pragma mark - Update methods

- (void)updateInBackground;
- (void)updateInBackground:(nullable void (^)(NSError * _Nullable error))block;

#pragma mark - Delete methods

- (void)deleteInBackground;
- (void)deleteInBackground:(nullable void (^)(NSError * _Nullable error))block;

#pragma mark - Fetch methods

- (void)fetchInBackground;
- (void)fetchInBackground:(nullable void (^)(NSError * _Nullable error))block;

@end

NS_ASSUME_NONNULL_END

