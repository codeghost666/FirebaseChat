//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessageSend1 : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(NSString *)groupId_ View:(UIView *)view_;

- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio;

@end

