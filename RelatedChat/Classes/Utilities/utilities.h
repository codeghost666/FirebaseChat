//
// Copyright (c) 2016 Ryan
//

#ifndef app_utilities_h
#define app_utilities_h

#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <PushKit/PushKit.h>

#pragma mark -

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <Firebase/Firebase.h>
#import <OneSignal/OneSignal.h>
#import <Realm/Realm.h>
#import <Sinch/Sinch.h>
#import <SinchService/SinchService.h>

#pragma mark -

#import "IQAudioRecorderViewController.h"
#import "JSQMessages.h"
#import "MBProgressHUD.h"
#import "ProgressHUD.h"
#import "Reachability.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"
#import "RNGridMenu.h"
#import "SWTableViewCell.h"

#pragma mark -

#import "AppConstant.h"

#pragma mark - advert

#import "premium.h"

#pragma mark - backend1

#import "FObject.h"
#import "FUser.h"
#import "FUser+Util.h"
#import "NSError+Util.h"

#pragma mark - backend2

#import "CallHistories.h"
#import "Groups.h"
#import "Messages.h"
#import "Recents.h"
#import "Users.h"
#import "UserStatuses.h"

#pragma mark - backend3

#import "Account.h"
#import "CallHistory.h"
#import "Group.h"
#import "Message.h"
#import "Recent.h"

#pragma mark - backend4

#import "chat.h"
#import "push.h"
#import "user.h"

#pragma mark - general1

#import "NotificationCenter.h"
#import "NSDictionary+Util.h"
#import "UserDefaults.h"

#pragma mark - general2

#import "Audio.h"
#import "Checksum.h"
#import "Cryptor.h"	
#import "Dir.h"
#import "Emoji.h"
#import "File.h"
#import "Image.h"
#import "Password.h"
#import "Video.h"

#pragma mark - general3

#import "camera.h"
#import "common.h"
#import "converter.h"

#pragma mark - manager

#import "AlbumManager.h"
#import "CacheManager.h"
#import "DownloadManager.h"
#import "MediaManager.h"

#pragma mark - mediaitems

#import "EmojiMediaItem.h"
#import "AudioMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"

#pragma mark - messages

#import "Connection.h"
#import "Incoming.h"
#import "MessageSend1.h"
#import "MessageSend2.h"
#import "MessageQueue.h"

#pragma mark - realm

#import "DBCallHistory.h"
#import "DBGroup.h"
#import "DBMessage.h"
#import "DBRecent.h"
#import "DBUser.h"
#import "DBUserStatus.h"

#endif

