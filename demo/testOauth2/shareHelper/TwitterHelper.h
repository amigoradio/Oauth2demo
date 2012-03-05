//
//  TwitterHelper.h
//  testOauth2
//
//  Created by radio on 12-1-19.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "OAUthConsumer.h"
#import "Reachability.h"
#import "MyDialog.h"

#define CALLBACK_URI    @""
#define CONSUMER_KEY    @""
#define CONSUMER_SECRET @""

@interface TwitterHelper : NSObject<MyDialogDelegate>{
    NSString *ACCESS_TOKEN;
    NSString *ACCESS_SECRET;
    MyDialog *dialog;
    OAConsumer * consumer;
    OAToken* accessToken;
    
    NSString *imageName;
    NSString *message;
}

- (void) startTwitter;
- (void) authTwitter;
- (void) sendTwitter;
- (void) sendImageTwitter;

@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *message;

@end
