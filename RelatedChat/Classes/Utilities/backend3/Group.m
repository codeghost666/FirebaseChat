//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

@implementation Group

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(NSString *)objectId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FIRDatabaseReference *firebase = [[[FIRDatabase database] referenceWithPath:FGROUP_PATH] child:objectId];
	[firebase updateChildValues:@{FGROUP_ISDELETED:@YES}];
}

@end

