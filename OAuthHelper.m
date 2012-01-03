//
//  Auth.m
//  testOauth2
//
//  Created by radio on 11-11-22.
//  Copyright (c) 2011年 pawdigits. All rights reserved.
//

#import "OAuthHelper.h"

@implementation OAuthHelper

- (id) init{
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OAuthAccessToken.cache"];
        accessToken = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath];
    }
    return self;
}

- (void) getAccessToken{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"mobile", @"display",
                                   @"token", @"response_type",
                                   sinaCallBackURL, @"redirect_uri",
								   sinaAppKey, @"client_id",
								   nil];
	NSURL *url = [self generateURL:sinaAuthBaseURL params:params];
	NSLog(@"firstURL=%@",url);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    CGSize size = [CCDirector sharedDirector].winSize;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [webView loadRequest:request];
    [webView setDelegate:self];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    [toolbar setTintColor:[UIColor redColor]];
    [toolbar sizeToFit];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [backbutton addTarget:self action:@selector(hiddenWebView) forControlEvents:UIControlEventTouchUpInside];
    [backbutton setFrame:CGRectMake(0, 0, 42, 31)];
    [backbutton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backbutton setBackgroundImage:[UIImage imageNamed:@"back_sel.png"] forState:UIControlStateSelected];
    
    UIBarButtonItem *infoButton=[[UIBarButtonItem alloc]initWithCustomView:backbutton];
    [toolbar setItems:[NSArray arrayWithObjects:infoButton,nil]]; 
    [webView addSubview:toolbar];
    [[[CCDirector sharedDirector] openGLView] addSubview:webView];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
		}
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSURL *url = [request URL];
    NSLog(@"url=%@",url);
	NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
    NSLog(@"array=%@",array);
    if ([array count]>1) {
        NSString *params = [array objectAtIndex:1];
        if ([params length] > 0) {
            NSRange token = [params rangeOfString:@"access_token"];
            if (token.location != NSNotFound) {
                [self viewSuccessPage:url];
            }
            NSRange error = [params rangeOfString:@"error_code"];
            if (error.location != NSNotFound) {
                [self viewErrorPage:url];
            }
            return NO;
        }
    }
	return YES;
}

- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	return str;
}

- (void)saveAccessTokenToDisk{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *writePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OAuthAccessToken.cache"];
    [NSKeyedArchiver archiveRootObject:accessToken toFile:writePath];
}

- (void) viewSuccessPage:(NSURL*)url{
    NSLog(@"viewSuccessPage");
    NSString *urlstr = [url absoluteString];
    NSString *token = [self getStringFromUrl:urlstr needle:@"access_token="];
    NSString *refreshToken = [self getStringFromUrl:urlstr needle:@"refresh_token="];
    NSString *expTime = [self getStringFromUrl:urlstr needle:@"expires_in="];
    NSDate *expirationDate =nil;
    NSLog(@"token=%@\nrefreshToken=%@\nexpTime=%@",token,refreshToken,expTime);
    if (expTime) {
        int expVal = [expTime intValue];
        if (expVal == 0) {
            expirationDate = [NSDate distantFuture];
        } else {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
			NSLog(@"time = %@",expirationDate);
        }
    }
    if (token) {
        accessToken = token;
        [self saveAccessTokenToDisk];
    }
    [self hiddenWebView];
    [self getUserId];
    //[self getUserInfo];
    //关注，取消关注
    //添加收藏
    //删除收藏
    //获取某条微博的评论列表
    //评论一条微博
    //回复一条微博
    //转发一条微博信息
    //发布一条微博信息
    //上传图片并发布一条微博
    //获取官方表情
    //获取用户发布的微博,用户最多只能请求到最近200条微博记录
    //根据ID获取单条微博信息
    //miyaxiaoxue
    //[self getBlogByUid];
    //[self uploadWeibo];
//    [self getWeiBo];
    [self uploadImageWeibo];
}

- (void) viewErrorPage:(NSURL*)url{
    NSLog(@"viewErrorPage");
    NSString *urlstr = [url absoluteString];
    NSString *errorUri = [self getStringFromUrl:urlstr needle:@"error_uri="];
    NSString *error = [self getStringFromUrl:urlstr needle:@"error="];
    NSString *errorDescription = [self getStringFromUrl:urlstr needle:@"error_description="];
    NSString *errorcode = [self getStringFromUrl:urlstr needle:@"error_code="];
    NSLog(@"errorUri=%@\nerror=%@\nerrorDescription=%@",errorUri,error,errorDescription);
    [self hiddenWebView];
}

- (void) hiddenWebView{
    NSLog(@"backToMain");
    [webView removeFromSuperview];
    NSLog(@"retainCount=%d",[webView retainCount]);
}

- (void) dealloc{
    [webView release];
    [accessToken release];
    [super dealloc];
}

- (void) getUserId{
    if (accessToken) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, @"access_token",nil];
        NSURL *url = [self generateURL:sinaUserIdURL params:params];
//        NSLog(@"url=%@",url);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        NSError *error = [request error];
        [request startSynchronous];
        if (!error) {
            NSString *response = [request responseString];
//            NSLog(@"response=%@",response);
            NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
//            NSLog(@"%@", dict);
            uid = (int)[dict objectForKey:@"uid"];
        }
    }
}

- (void) getUserInfo{
    if (accessToken && uid != 0) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, @"access_token",
                                       uid, @"uid",
                                       nil];
        NSURL *url = [self generateURL:sinaUserInfoURL params:params];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk:)];
        [request setDidFailSelector:@selector(requestError:)];
    }
}

- (void) requestOk:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    NSLog(@"userInfo=%@",dict);
}

- (void) requestError:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"error=%@",error);
}

- (void) getBlogByUid{
    if (accessToken && uid != 0) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, @"access_token",
                                       @"2473071025", @"uid",
                                       @"5",@"count",
                                       @"1",@"page",
                                       @"1",@"trim_user",
                                       nil];
        NSURL *url = [self generateURL:@"https://api.weibo.com/2/statuses/user_timeline.json" params:params];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk1:)];
        [request setDidFailSelector:@selector(requestError1:)];
    }
}

- (void) requestOk1:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    NSLog(@"1userInfo=%@",dict);
}

- (void) requestError1:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"1error=%@",error);
}

- (void) uploadWeibo{
    if (accessToken && uid != 0) {
//        NSArray *array = [NSArray arrayWithObjects:@"abc",@"123",@"哈哈",@"456", nil];
//        NSString *json = [[CJSONSerializer serializer] serializeArray:array];
        NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:accessToken forKey:@"access_token"];
        [request setPostValue:@"123123我是谁wdsds2" forKey:@"status"];
//        [request setPostValue:json forKey:@"annotations"];
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk1:)];
        [request setDidFailSelector:@selector(requestError1:)];
    }
}

//测试的时候这个接口经常出现问题，貌似那时候sina的服务不稳定
- (void) uploadImageWeibo{
    if (accessToken) {
        NSLog(@"acc=%@",accessToken);
        NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:accessToken forKey:@"access_token"];
        [request setPostValue:@"111上传的图片hahaha" forKey:@"status"];
        UIImage *image = [UIImage imageNamed:@"abc.jpg"];
        [request setTimeOutSeconds:30];
        NSData *imageData = UIImageJPEGRepresentation(image,cosf(0.7));
        [request setData:imageData forKey:@"pic"];
//        NSString *defaultPlistName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"assign.png"];
//        [request setFile:defaultPlistName forKey:@"pic"]; 
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk1:)];
        [request setDidFailSelector:@selector(requestError1:)];
    }
}

- (void) getWeiBo{
    if (accessToken) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, @"access_token",
                                       @"3385558556944411", @"id",
                                       nil];
        NSURL *url = [self generateURL:@"https://api.weibo.com/2/statuses/show.json" params:params];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request startAsynchronous];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestOk1:)];
        [request setDidFailSelector:@selector(requestError1:)];
    }
}

@end
