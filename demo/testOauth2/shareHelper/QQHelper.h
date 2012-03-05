//
//  QQHelper.h
//  testOauth2
//
//  Created by radio on 12-2-7.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "cocos2d.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "MyDialog.h"
#import "LoadingLayer.h"

#define qqAppID @""
#define qqAppKey @""
#define qqAppSecret @""
#define qqAuthBaseURL @"https://graph.qq.com/oauth2.0/authorize"
#define qqCallBackURL @""
#define qqAccessTokenURL @"https://graph.renren.com/oauth/token"
#define qqOpenIdURL @"https://graph.qq.com/oauth2.0/me"
#define qqUploadURL @"https://graph.qq.com/t/add_pic_t"

@interface QQHelper : NSObject<MyDialogDelegate,ASIHTTPRequestDelegate>{
    NSString *accessToken;
    MyDialog *dialog;
    int openId;
    NSString *imageName;
    NSString *message;
}

@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *message;

- (void) startShare;
- (void) userAuth;
- (void) getOpenId;
- (void) sharePhoto;

@end

