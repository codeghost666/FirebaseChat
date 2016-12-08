//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

#import "StickersView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView : JSQMessagesViewController <RNGridMenuDelegate, UIImagePickerControllerDelegate, IQAudioRecorderViewControllerDelegate, StickersDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(NSDictionary *)dictionary;

@end

