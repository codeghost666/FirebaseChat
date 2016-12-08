//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* TimeElapsed(NSTimeInterval seconds)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *elapsed;
	if (seconds < 60)
	{
		elapsed = @"Just now";
	}
	else if (seconds < 60 * 60)
	{
		int minutes = (int) (seconds / 60);
		elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
	}
	else if (seconds < 24 * 60 * 60)
	{
		int hours = (int) (seconds / (60 * 60));
		elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
	}
	else
	{
		int days = (int) (seconds / (24 * 60 * 60));
		elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
	}
	return elapsed;
}

