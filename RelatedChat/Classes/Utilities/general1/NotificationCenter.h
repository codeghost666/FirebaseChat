//
// Copyright (c) 2016 Ryan
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface NotificationCenter : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name;

+ (void)removeObserver:(id)target;

+ (void)post:(NSString *)notification;

@end

