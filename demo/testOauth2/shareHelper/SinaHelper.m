//
//  SinaHelper.m
//  testOauth2
//
//  Created by radio on 12-2-8.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "SinaHelper.h"
#import "Reachability.h"

@implementation SinaHelper

@synthesize imageName,message;

//读取accseToken的过期时间，没过期则继续使用accessToken，过期则accessToken为nil
- (id) init{
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sinaExpiresIn"];
        NSDate *expirationDate = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath];
        if (expirationDate) {
            NSDate *now = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:now];
            now = [now dateByAddingTimeInterval:interval];
            if ([now compare:expirationDate] == NSOrderedAscending) {
                NSString *writePath2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sinaAccessToken"];
                accessToken = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath2];
            }
        }
    }
    return self;
}

//判断网络是否可用，判断accessToken是否存在，存在则直接分享图片，不存在则进行用户认证
- (void) startShare{
    Reachability *reach = [Reachability reachabilityForInternetConnection];    
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    if (netStatus == NotReachable) {
        UIAlertView* connectalert = [[UIAlertView alloc] initWithTitle:@"网络检查"
                                                               message:@"请检查您的网络，稍候进行分享"
                                                              delegate:self cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil];
        [connectalert show];
        [connectalert release];
    }else{
        if (accessToken) {
            [self sharePhoto];
        }else{
            [self userAuth];
        }
    }
}

//用户使用Oauth2进行认证，认证页面在UIWebView中进行显示
- (void) userAuth{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"mobile", @"display",
                                   @"token", @"response_type",
                                   sinaCallBackURL, @"redirect_uri",
								   sinaAppKey, @"client_id",
								   nil];
    dialog = [[MyDialog alloc] initWithURL:sinaAuthBaseURL params:params delegate:self webViewFlag:NO];
    [dialog showDialog];
}

//获取UIWebView中的url进行分析，获得accessToken和expires，将过期时间保存，将accessToken保存.
- (void) dialogDidSucceed:(NSURL*)url{
    NSString *urlstr = [url absoluteString];
    NSString *token = [dialog getStringFromUrl:urlstr needle:@"access_token="];
//    NSString *refreshToken = [dialog getStringFromUrl:urlstr needle:@"refresh_token="];
    NSString *expTime = [dialog getStringFromUrl:urlstr needle:@"expires_in="];
    NSDate *expirationDate =nil;
    //NSLog(@"token=%@\nrefreshToken=%@\nexpTime=%@",token,refreshToken,expTime);
    if (expTime) {
        int expVal = [expTime intValue];
        if (expVal == 0) {
            expirationDate = [NSDate distantFuture];
        } else {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
        }
        //NSLog(@"time = %@",expirationDate);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sinaExpiresIn"];
        [NSKeyedArchiver archiveRootObject:expirationDate toFile:writePath];
    }
    if (token && (token.length != 0)) {
        accessToken = token;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sinaAccessToken"];
        [NSKeyedArchiver archiveRootObject:accessToken toFile:writePath];
    }
}

- (void) dismissWithUrl:(NSURL*)url{
    NSLog(@"dismissWithUrl=%@",url);
    NSString *urlstr = [url absoluteString];
    NSString *errorUri = [dialog getStringFromUrl:urlstr needle:@"error_uri="];
    NSString *error = [dialog getStringFromUrl:urlstr needle:@"error="];
    NSString *errorDescription = [dialog getStringFromUrl:urlstr needle:@"error_description="];
    NSString *errorcode = [dialog getStringFromUrl:urlstr needle:@"error_code="];
    NSLog(@"errorUri=%@\nerror=%@\nerrorDescription=%@\nerrorcode=%@",errorUri,error,errorDescription,errorcode);
}

//分享照片功能
- (void) sharePhoto{
    NSLog(@"sharePhoto accessToken=%@",accessToken);
    if (accessToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
        NSURL *url = [NSURL URLWithString:sinaUploadURL];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:accessToken forKey:@"access_token"];
        [request setPostValue:message forKey:@"status"];
        UIImage *image = [UIImage imageNamed:imageName];
        [request setTimeOutSeconds:30];
        [request setData:UIImagePNGRepresentation(image) withFileName:@"myphoto.png" andContentType:@"image/png" forKey:@"pic"];
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk:)];
        [request setDidFailSelector:@selector(requestError:)];
    }
}

- (void) requestOk:(ASIHTTPRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
    NSString *response = [request responseString];
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    NSLog(@"sharePhoto success=%@",dict);
}

- (void) requestError:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"sharePhoto error=%@",error);
}

- (void) dealloc{
    [imageName release];
    [message release];
    [dialog release];
    [accessToken release];
    [super dealloc];
}

@end

