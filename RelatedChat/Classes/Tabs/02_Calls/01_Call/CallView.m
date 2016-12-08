//
// Copyright (c) 2016 Ryan
//

#import "CallView.h"
#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallView()
{
	DBUser *dbuser;
	NSTimer *timer;
	BOOL incoming, outgoing;
	BOOL muted, speaker;

	id<SINCall> call;
	id<SINAudioController> audioController;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) IBOutlet UIView *viewButtons;
@property (strong, nonatomic) IBOutlet UIButton *buttonMute;
@property (strong, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;

@property (strong, nonatomic) IBOutlet UIView *viewButtons1;
@property (strong, nonatomic) IBOutlet UIView *viewButtons2;

@property (strong, nonatomic) IBOutlet UIView *viewEnded;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CallView


@end

