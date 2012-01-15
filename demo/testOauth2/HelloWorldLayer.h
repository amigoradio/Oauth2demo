//
//  HelloWorldLayer.h
//  testOauth2
//
//  Created by cheng gong on 11-11-21.
//  Copyright __MyCompanyName__ 2011年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "OAuthHelper.h"
// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (void) login;
- (void) logout;
- (void) share;
@end
