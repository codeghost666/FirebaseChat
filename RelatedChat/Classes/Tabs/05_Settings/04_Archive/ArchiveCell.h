//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ArchiveCell : SWTableViewCell
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)bindData:(DBRecent *)dbrecent;

- (void)loadImage:(DBRecent *)dbrecent TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;

@end

