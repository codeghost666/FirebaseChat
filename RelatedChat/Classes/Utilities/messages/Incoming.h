//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Incoming : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(DBMessage *)dbmessage_ CollectionView:(JSQMessagesCollectionView *)collectionView_;

- (JSQMessage *)createMessage;

@end

