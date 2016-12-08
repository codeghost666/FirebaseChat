//
// Copyright (c) 2016 Ryan
//

#import "PremiumView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ActionPremium(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PremiumView *premiumView = [[PremiumView alloc] init];
	premiumView.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[window.rootViewController presentViewController:premiumView animated:YES completion:nil];
}

