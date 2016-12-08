//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PresentAudioRecorder(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IQAudioRecorderViewController *controller = [[IQAudioRecorderViewController alloc] init];
	controller.delegate = target;
	controller.title = @"Recorder";
	controller.maximumRecordDuration = AUDIO_LENGTH;
	controller.allowCropping = NO;
	[target presentBlurredAudioRecorderViewControllerAnimated:controller];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* Filename(NSString *type, NSString *ext)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int interval = (int) [[NSDate date] timeIntervalSince1970];
	return [NSString stringWithFormat:@"%@/%@/%d.%@", [FUser currentId], type, interval, ext];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* UserNamesFor(NSArray *members, NSString *userId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *names = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBUser *dbuser in [[DBUser allObjects] sortedResultsUsingProperty:FUSER_FULLNAME ascending:YES])
	{
		if ([members containsObject:dbuser.objectId])
		{
			if ([dbuser.objectId isEqualToString:userId] == NO)
				[names addObject:dbuser.fullname];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [names componentsJoinedByString:@", "];
}

