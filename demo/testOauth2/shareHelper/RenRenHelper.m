//
//  RenRenHelper.m
//  testOauth2
//
//  Created by radio on 12-2-2.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "RenRenHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"

@implementation RenRenHelper

@synthesize imageName,message;

- (id) init{
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"renrenExpiresIn"];
        NSDate *expirationDate = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath];
        if (expirationDate) {
            NSDate *now = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:now];
            now = [now dateByAddingTimeInterval:interval];
            if ([now compare:expirationDate] == NSOrderedAscending) {
                NSString *writePath2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"renrenAcessToken"];
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
            [self sharePhoto];
        }else{
            [self userAuth];
        }
    }
}

- (void) userAuth{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"token", @"response_type",
                                   renCallBackURL, @"redirect_uri",
								   renAppKey, @"client_id",
                                   @"photo_upload",@"scope",
								   nil];
    dialog = [[MyDialog alloc] initWithURL:renAuthBaseURL params:params delegate:self webViewFlag:NO];
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
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"renrenExpiresIn"];
        [NSKeyedArchiver archiveRootObject:expirationDate toFile:writePath];
    }
    if (token && (token.length != 0)){
        accessToken = token;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"renrenAcessToken"];
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

//其他都与sina的一样，但调用api时要多传递一个sig的参数
- (void) sharePhoto{
    NSLog(@"sharePhoto accessToken=%@",accessToken);
    if (accessToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
        NSDate *now = [NSDate date];
        NSString *time = [NSString stringWithFormat:@"%d",(int)[now timeIntervalSince1970]];
        NSLog(@"sharePhoto time=%@",time);
        NSURL *url = [NSURL URLWithString:renApiURL];
        NSArray *keys = [NSArray arrayWithObjects:@"access_token",@"method",@"v",@"format",@"caption", nil];
        NSArray *values = [NSArray arrayWithObjects:accessToken,@"photos.upload",@"1.0",@"json",message, nil];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [self buildRequest:dict req:request];
        [request setPostValue:[self buildSig:dict] forKey:@"sig"];
        [request setTimeOutSeconds:30];
        UIImage *image = [UIImage imageNamed:imageName];
        [request setData:UIImagePNGRepresentation(image) withFileName:@"myphoto.png" andContentType:@"image/png" forKey:@"upload"];
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

//将参数排序，与sig中的构建顺序有关
- (void) buildRequest:(NSMutableDictionary *) dict req:(ASIFormDataRequest *) request{
    NSArray *keys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString * key in keys) {
        NSString *value = [dict objectForKey:key];
        [request setPostValue:value forKey:key];
    }
}

//组装一个sig的参数，具体方法看人人的开发文档
- (NSString *) buildSig:(NSMutableDictionary *) dict{
    NSArray *keys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableString *string = [NSMutableString stringWithCapacity:20]; 
    for (NSString * key in keys) {
        NSString *value = [dict objectForKey:key];
        [string appendFormat:@"%@=%@",key,value];
    }
    [string appendString:renAppSecret];
    //NSLog(@"sig String=%@",string);
    return [self md5:string];
}

//将sig的值进行md5
- (NSString *) md5:(NSString *) str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],
            result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]] lowercaseString];
}

- (void) dealloc{
    [imageName release];
    [message release];
    [dialog release];
    [accessToken release];
    [super dealloc];
}

@end

