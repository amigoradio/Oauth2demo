//
//  MailHelper.h
//  testOauth2
//
//  Created by radio on 12-3-18.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MailHelper : NSObject<MFMailComposeViewControllerDelegate>

- (void) sendmail:(NSString*) title body:(NSString*) bodyText imageName:(NSString*) name;
- (void)launchMailAppOnDevice;

@end
