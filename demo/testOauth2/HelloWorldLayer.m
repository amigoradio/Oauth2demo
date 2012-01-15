//
//  HelloWorldLayer.m
//  testOauth2
//
//  Created by cheng gong on 11-11-21.
//  Copyright __MyCompanyName__ 2011年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        CCMenuItemFont *item1 = [CCMenuItemFont itemFromString:@"login" target:self selector:@selector(login)];
         CCMenuItemFont *item2 = [CCMenuItemFont itemFromString:@"logout" target:self selector:@selector(logout)];
         CCMenuItemFont *item3 = [CCMenuItemFont itemFromString:@"share" target:self selector:@selector(share)];
        CCMenu *menu = [CCMenu menuWithItems:item1,item2,item3, nil];
        [menu alignItemsHorizontallyWithPadding:20];
        menu.position = ccp(200,100);
        [self addChild:menu];
	}
	return self;
}

- (void) login{
    NSLog(@"login sina");
    OAuthHelper *auth = [[OAuthHelper alloc] init];
//    [auth getAuthCode];//mobile项目不需要使用code
    [auth getAccessToken];
}

- (void) logout{
    NSLog(@"logout sina");
}

- (void) share{
    NSLog(@"share image");
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
