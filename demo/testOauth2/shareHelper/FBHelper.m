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

- (void) startFacebook{
    Reachability *reach = [Reachability reachabilityForInternetConnection];    
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    if (netStatus == NotReachable) {
        //NSLog(@"No internet connection!");
        UIAlertView* connectalert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"s18", nil)
                                                               message:NSLocalizedString(@"s19", nil)
                                                              delegate:self cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil];
        [connectalert show];
        [connectalert release];
    }else{
        if (facebook.accessToken) {
            [self sendImage];
        }else{
            [self authFacebook];
        }
    }
}

- (void) authFacebook{
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
        [self sendImage];
    }

}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    //NSLog(@"fbDidLogin=%@",[facebook accessToken]);
    [self sendImage];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"Login cancelled. No Login, No Share, No Game! :)");
    } else {
        NSLog(@"fb login Error. Please try again.");
    }
}

- (void)sendImage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayLoading" object:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:imageName];
    NSData *imageData= UIImagePNGRepresentation(image);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message, @"message", imageData, @"source", nil];
    [facebook requestWithGraphPath:@"/me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    //NSLog(@"Photo posted in the \"APP NAME\" album on your account!=%@",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLoading" object:nil];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"fb photo upload Error %@",error);
}

- (void) dealloc{
    [facebook release];
    [imageName release];
    [message release];
    [super dealloc];
}

@end
