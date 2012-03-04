//
//  QQHelper.m
//  testOauth2
//
//  Created by radio on 12-2-7.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "QQHelper.h"
#import "Reachability.h"

@implementation QQHelper

@synthesize imageName,message;

- (id) init{
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"qqExpiresIn"];
        NSDate *expirationDate = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath];
        if (expirationDate) {
            NSDate *now = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:now];
            now = [now dateByAddingTimeInterval:interval];
            if ([now compare:expirationDate] == NSOrderedAscending) {
                NSString *writePath2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"qqAccessToken"];
                accessToken = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath2];
            }
        }
    }
    return self;
}

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
            [self getOpenId];
            [self sharePhoto];
        }else{
            [self userAuth];
        }
    }
}

- (void) userAuth{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"token", @"response_type",
                                   qqCallBackURL, @"redirect_uri",
								   qqAppID, @"client_id",
                                   @"mobile",@"display",
                                   @"add_pic_t",@"scope",
								   nil];
    dialog = [[MyDialog alloc] initWithURL:qqAuthBaseURL params:params delegate:self webViewFlag:NO];
    [dialog showDialog];
}

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
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"qqExpiresIn"];
        [NSKeyedArchiver archiveRootObject:expirationDate toFile:writePath];
    }
    if (token && (token.length != 0)){
        accessToken = token;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"qqAcessToken"];
        [NSKeyedArchiver archiveRootObject:accessToken toFile:writePath];
    }
    [self getOpenId];
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

//使用accessToke来获取openID,获取的返回值带有callback()所以要去掉这些字符和回车空格，然后在进行json的处理
- (void) getOpenId{
    if (accessToken) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, @"access_token",nil];
        NSURL *url = [dialog generateURL:qqOpenIdURL params:params];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        NSError *error = [request error];
        [request startSynchronous];
        if (!error) {
            NSString *response = [request responseString];
            response = [response stringByReplacingOccurrencesOfString:@"callback(" withString:@""];
            response = [response stringByReplacingOccurrencesOfString:@");" withString:@""];
            response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
            NSLog(@"get openID result=%@", dict);
            openId = (int)[dict objectForKey:@"openid"];
        }else{
            openId = 0;
            NSLog(@"get openid error=%@",error);
        }
    }
}

//与sina一样，传递时需要传递openID参数
- (void) sharePhoto{
    NSLog(@"sharePhoto accessToken=%@ openid=%d",accessToken,openId);
    if (accessToken && openId != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
        NSURL *url = [NSURL URLWithString:qqUploadURL];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:accessToken forKey:@"access_token"];
        [request setPostValue:qqAppID forKey:@"oauth_consumer_key"];
        [request setPostValue:[NSNumber numberWithInt:openId] forKey:@"openid"];
        [request setPostValue:@"json" forKey:@"format"];
        [request setPostValue:message forKey:@"content"];
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
    NSLog(@"response=%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    NSLog(@"1userInfo=%@",dict);
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

