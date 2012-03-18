//
//  TwitterHelper.m
//  testOauth2
//
//  Created by radio on 12-1-19.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "TwitterHelper.h"

@implementation TwitterHelper

@synthesize imageName,message;

- (id)init
{
    //ACCESS_TOKEN don't expire unless a user manually expires
    NSUserDefaults *userdata = [NSUserDefaults standardUserDefaults];
    ACCESS_TOKEN = [userdata stringForKey:@"twAccessToken"];
    ACCESS_SECRET = [userdata stringForKey:@"twAccessSecrt"];
    message = @"";
    return [super init];
}

- (void) shareText
{
    OAToken *oaToken = [[[OAToken alloc] initWithKey:ACCESS_TOKEN
                                         secret:ACCESS_SECRET] autorelease];
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
    OAMutableURLRequest* request = [[[OAMutableURLRequest alloc] 
                                     initWithURL:url consumer:consumer token:oaToken
                                     realm:nil signatureProvider:nil] autorelease];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *requestParam = [[OARequestParameter alloc] initWithName:@"status" value:message];
    NSArray* params = [NSArray arrayWithObjects:requestParam, nil];
    [request setParameters:params];
    OADataFetcher* fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request delegate:self
                didFinishSelector:@selector(ticket:didFinishWithTweet:)
                  didFailSelector:@selector(ticket:didFailWithTweetError:)];
    [requestParam release];
}

- (void) sharePhoto
{
    if (imageName) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
        OAToken *oaToken = [[[OAToken alloc] initWithKey:ACCESS_TOKEN
                                                  secret:ACCESS_SECRET] autorelease];
        NSURL *url = [NSURL URLWithString:@"http://upload.twitter.com/1/statuses/update_with_media.json"];
        OAMutableURLRequest* request = [[[OAMutableURLRequest alloc] 
                                         initWithURL:url consumer:consumer token:oaToken
                                         realm:nil signatureProvider:nil] autorelease];
        [request setHTTPMethod:@"POST"];
        OARequestParameter *requestParam = [[OARequestParameter alloc] initWithName:@"status" value:message];
        NSArray* params = [NSArray arrayWithObjects:requestParam, nil];
        [request setParameters:params];
        UIImage *image = [UIImage imageWithContentsOfFile:imageName];
        [request attachFileWithName:@"media[]" filename:@"photos.png" contentType:@"image/png" data:UIImagePNGRepresentation(image)];
        OADataFetcher* fetcher = [[[OADataFetcher alloc] init] autorelease];
        [fetcher fetchDataWithRequest:request delegate:self
                    didFinishSelector:@selector(ticket:didFinishWithTweet:)
                      didFailSelector:@selector(ticket:didFailWithTweetError:)];
        [requestParam release];
    }
}

- (void)ticket:(OAServiceTicket *)ticket didFinishWithTweet:(NSData *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithTweetError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
    NSLog(@"twitter share photo failed %@",error);
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
        if (ACCESS_TOKEN && ACCESS_SECRET) {
            [self sharePhoto];
        }else{
            [self userAuth];
        }
    }
}

- (void) userAuth{
    consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET];
    OADataFetcher* fetcher = [[[OADataFetcher alloc] init] autorelease];
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc]
                                     initWithURL:url
                                     consumer:consumer
                                     token:nil
                                     realm:nil
                                     signatureProvider:nil]autorelease];
    [request setHTTPMethod:@"POST"];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishGetRequestToken:)
                  didFailSelector:@selector(requestTokenTicket:didFailTwitterSubmitterWithError:)];
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFinishGetRequestToken:(NSData*)data
{
    if (ticket.didSucceed) {
        NSString *responseBody = [[[NSString alloc]
                                   initWithData:data 
                                   encoding:NSUTF8StringEncoding]autorelease];
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accessToken.key, @"oauth_token",
                                       @"true", @"force_login",
                                        nil];
        dialog = [[MyDialog alloc] initWithURL:@"https://api.twitter.com/oauth/authorize" params:params delegate:self webViewFlag:YES];
        [dialog showDialog];
    } else {
        NSLog(@"twitter ticket.failed");
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

- (BOOL)backFromBrowser:(NSURL*)responseURL
{
    NSURL* resulturl = [NSURL URLWithString:CALLBACK_URI];
    if ([[responseURL host] isEqualToString:[resulturl host]]) {
        accessToken = [accessToken initWithHTTPResponseBody:[responseURL query]];
        OADataFetcher* fetcher = [[[OADataFetcher alloc] init] autorelease];
        NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
        OAMutableURLRequest* request = [[[OAMutableURLRequest alloc]
                                     initWithURL:url
                                     consumer:consumer
                                     token:accessToken
                                     realm:nil
                                     signatureProvider:nil] autorelease];
        [request setHTTPMethod:@"POST"];
        [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishfetchAccessToken:)
                  didFailSelector:@selector(requestTokenTicket:didFailTwitterSubmitterWithError:)];
        return YES;
    }
    return NO;
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFinishfetchAccessToken:(NSData*)data
{
    if (ticket.didSucceed) {
        NSString* responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        accessToken = [accessToken initWithHTTPResponseBody:responseBody];
        ACCESS_TOKEN  = accessToken.key;
        ACCESS_SECRET = accessToken.secret;
        NSUserDefaults *userdata = [NSUserDefaults standardUserDefaults];
        [userdata setObject:ACCESS_TOKEN forKey:@"twAccessToken"];
        [userdata setObject:ACCESS_SECRET forKey:@"twAccessSecrt"];
        if ([userdata synchronize]) {
            [self sharePhoto];
        }
    } else {
        NSLog(@"twitter access_token.failed");
    }
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFailTwitterSubmitterWithError:(NSError*)error{
    NSLog(@"didFailTwitterSubmitterWithError=%@",error);
}

- (void) dealloc{
    [imageName release];
    [message release];
    [ACCESS_TOKEN release];
    [ACCESS_SECRET release];
    [dialog release];
    [consumer release];
    [accessToken release];
    [super dealloc];
}

@end
