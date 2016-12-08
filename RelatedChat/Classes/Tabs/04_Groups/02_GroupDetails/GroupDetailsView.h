//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

#import "SelectMultipleView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupDetailsView : UITableViewController <UIImagePickerControllerDelegate, SelectMultipleDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(NSString *)groupId Chat:(BOOL)chat;

@end

