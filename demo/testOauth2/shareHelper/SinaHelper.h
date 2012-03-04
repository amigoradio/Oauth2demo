//
//  SinaHelper.h
//  testOauth2
//
//  Created by radio on 12-2-8.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "cocos2d.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "MyDialog.h"

#define sinaAppKey @""
#define sinaAppSecret @""
#define sinaAuthBaseURL @"https://api.weibo.com/oauth2/authorize"
#define sinaCallBackURL @""
#define sinaAccessTokenURL @"https://api.weibo.com/oauth2/access_token"
#define sinaUploadURL @"https://api.weibo.com/2/statuses/upload.json"

@interface SinaHelper : NSObject<MyDialogDelegate,ASIHTTPRequestDelegate>{
    NSString *accessToken;
    MyDialog *dialog;
    NSString *imageName;
    NSString *message;
}

@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *message;

- (void) startShare;
- (void) userAuth;
- (void) sharePhoto;

@end
