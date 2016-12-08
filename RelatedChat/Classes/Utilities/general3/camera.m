//
// Copyright (c) 2016 Ryan
//

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL PresentPhotoCamera(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeImage;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type])
	{
		imagePicker.mediaTypes = @[type];
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		}
		else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		}
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.allowsEditing = canEdit;
	imagePicker.showsCameraControls = YES;
	imagePicker.delegate = target;
	[target presentViewController:imagePicker animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL PresentVideoCamera(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeMovie;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type])
	{
		imagePicker.mediaTypes = @[type];
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.videoMaximumDuration = VIDEO_LENGTH;

		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		}
		else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		}
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.allowsEditing = canEdit;
	imagePicker.showsCameraControls = YES;
	imagePicker.delegate = target;
	[target presentViewController:imagePicker animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL PresentMultiCamera(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type1 = (NSString *)kUTTypeImage;
	NSString *type2 = (NSString *)kUTTypeMovie;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type1])
	{
		imagePicker.mediaTypes = @[type1, type2];
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.videoMaximumDuration = VIDEO_LENGTH;

		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		}
		else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
		{
			imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		}
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.allowsEditing = canEdit;
	imagePicker.showsCameraControls = YES;
	imagePicker.delegate = target;
	[target presentViewController:imagePicker animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL PresentPhotoLibrary(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
		 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeImage;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.mediaTypes = @[type];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
			 && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		imagePicker.mediaTypes = @[type];
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.allowsEditing = canEdit;
	imagePicker.delegate = target;
	[target presentViewController:imagePicker animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL PresentVideoLibrary(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
		 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeMovie;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.videoMaximumDuration = VIDEO_LENGTH;

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.mediaTypes = @[type];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
			 && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		imagePicker.mediaTypes = @[type];
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imagePicker.allowsEditing = canEdit;
	imagePicker.delegate = target;
	[target presentViewController:imagePicker animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

