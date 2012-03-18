//
//  FBOauth2.h
//  testOauth2
//
//  Created by radio on 12-2-2.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define fbAppKey @""
#define fbAppSecret @""

@interface FBHelper : NSObject<FBSessionDelegate,FBRequestDelegate>{
    Facebook *facebook;
    NSString *imageName;
    NSString *message;
}

@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *message;
@property (nonatomic, retain) Facebook *facebook;

- (void) sharePhoto;
- (void) startShare;
- (void) userAuth;



@end
