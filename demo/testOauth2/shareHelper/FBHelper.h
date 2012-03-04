//
//  FBOauth2.h
//  testOauth2
//
//  Created by radio on 12-2-2.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define fbAppKey @"276110775774242"
#define fbAppSecret @"a6816d8a9d493040dc6824470970a346"

@interface FBHelper : NSObject<FBSessionDelegate,FBRequestDelegate>{
    Facebook *facebook;
    NSString *imageName;
    NSString *message;
}

@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *message;
@property (nonatomic, retain) Facebook *facebook;

- (void) sendImage;
- (void) startFacebook;
- (void) authFacebook;



@end
