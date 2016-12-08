//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@protocol SelectMultipleDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)didSelectMultipleUsers:(NSMutableArray *)users;

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SelectMultipleView : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, assign) IBOutlet id<SelectMultipleDelegate>delegate;

@end

