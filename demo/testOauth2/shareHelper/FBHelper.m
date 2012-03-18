//
//  FBOauth2.m
//  testOauth2
//
//  Created by radio on 12-2-2.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "FBHelper.h"
#import "Reachability.h"

@implementation FBHelper

@synthesize facebook,imageName,message;

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
        if (facebook.accessToken) {
            [self sharePhoto];
        }else{
            [self userAuth];
        }
    }
}

- (void) userAuth{
    facebook = [[Facebook alloc] initWithAppId:fbAppKey andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook isSessionValid]) {
        NSArray* permissions =  [[NSArray arrayWithObjects:
                                  @"publish_stream", nil] retain];
        [facebook authorize:permissions];
    }else{
        [self sharePhoto];
    }

}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self sharePhoto];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"Login cancelled. No Login, No Share, No Game! :)");
    } else {
        NSLog(@"fb login Error. Please try again.");
    }
}

- (void)sharePhoto{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:imageName];
    NSData *imageData= UIImagePNGRepresentation(image);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message, @"message", imageData, @"source", nil];
    [facebook requestWithGraphPath:@"/me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"Photo posted in the \"APP NAME\" album on your account!=%@",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
    NSLog(@"fb photo upload Error %@",error);
}

- (void) dealloc{
    [facebook release];
    [imageName release];
    [message release];
    [super dealloc];
}

@end
