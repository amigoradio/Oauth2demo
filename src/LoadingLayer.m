//
//  LoadingLayer.m
//  HitFace
//
//  Created by cheng gong on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoadingLayer.h"

@implementation LoadingLayer

- (id) initText:(NSString *) text{
    if ((self = [super initWithColor:ccc4(0, 0, 0, 178)])) {
        self.isTouchEnabled = YES;
        CGSize winsize = [[CCDirector sharedDirector] winSize];
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = ccp(winsize.width/2,winsize.height/2);
        [indicator startAnimating];
        [[[CCDirector sharedDirector] openGLView] addSubview:indicator];
        [indicator release];

        CCLabelTTF *message = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:20];
        message.color = ccWHITE;
        message.position = ccp(240,100);
        [self addChild:message];
    }
    return self;
}

- (void) clearIndicator{
    [indicator removeFromSuperview];
    indicator = nil;
}

- (void) registerWithTouchDispatcher{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}

@end
