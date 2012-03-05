//
//  RenRenHelper.h
//  testOauth2
//
//  Created by radio on 12-2-2.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "cocos2d.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "MyDialog.h"

#define renAppID @""
#define renAppKey @""
#define renAppSecret @""
#define renAuthBaseURL @"https://graph.renren.com/oauth/authorize"
#define renCallBackURL @"http://graph.renren.com/oauth/login_success.html"
#define renAccessTokenURL @"https://graph.renren.com/oauth/token"
#define renApiURL @"http://api.renren.com/restserver.do"

@interface RenRenHelper : NSObject<MyDialogDelegate,ASIHTTPRequestDelegate>{
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

- (void) buildRequest:(NSMutableDictionary *) dict req:(ASIFormDataRequest *) request;
- (NSString *) buildSig:(NSMutableDictionary *) dict;
- (NSString *) md5:(NSString *) str;

@end
