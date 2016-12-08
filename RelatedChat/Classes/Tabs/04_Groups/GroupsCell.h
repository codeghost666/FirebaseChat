//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsCell : UITableViewCell
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)bindData:(DBGroup *)dbgroup;

- (void)loadImage:(DBGroup *)dbgroup TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;

@end

