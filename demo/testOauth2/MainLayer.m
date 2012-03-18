//
//  MainLayer.m
//  testOauth2
//
//  Created by radio on 12-3-4.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "MainLayer.h"
#import "SinaHelper.h"
#import "RenRenHelper.h"
#import "QQHelper.h"
#import "MailHelper.h"
#import "TwitterHelper.h"
#import "FBHelper.h"

@implementation MainLayer

+ (CCScene *) scene{
    CCScene *scene = [CCScene node];
    MainLayer *layer = [MainLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayLoadingLayer) name:@"displayLoading" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeLoadingLayer) name:@"closeLoading" object:nil];
        
        [CCMenuItemFont setFontSize:20];
        CCMenuItemFont *sina = [CCMenuItemFont itemFromString:@"sinaLogin" 
                                                        block:^(id sender){
                                                            SinaHelper *sina = [[SinaHelper alloc] init];
                                                            [sina userAuth];
                                                        }];
        sina.color = ccRED;
        CCMenuItemFont *renren = [CCMenuItemFont itemFromString:@"renrenLogin" 
                                                          block:^(id sender){
                                                              RenRenHelper *renren = [[RenRenHelper alloc] init];
                                                              [renren userAuth];
                                                          }];
        renren.color = ccGREEN;
        CCMenuItemFont *qq = [CCMenuItemFont itemFromString:@"qqLogin" 
                                                      block:^(id sender){
                                                          QQHelper *qq = [[QQHelper alloc] init];
                                                          [qq userAuth];
                                                      }];
        qq.color = ccBLUE;
        CCMenuItemFont *twitter = [CCMenuItemFont itemFromString:@"twitterLogin" 
                                                           block:^(id sender){
                                                               TwitterHelper *twitter = [[TwitterHelper alloc] init];
                                                               [twitter userAuth];
                                                           }];
        twitter.color = ccMAGENTA;
        CCMenuItemFont *facebook = [CCMenuItemFont itemFromString:@"faceboookLogin" 
                                                            block:^(id sender){
                                                                FBHelper *fb = [[FBHelper alloc] init];
                                                                [fb userAuth];
                                                            }];
        facebook.color = ccYELLOW;
        
        CCMenu *menu = [CCMenu menuWithItems:sina,renren,qq,twitter,facebook, nil];
        menu.position = ccp(100,180);
        [menu alignItemsVerticallyWithPadding:10];
        [self addChild:menu];
        
        CCMenuItemFont *sinaSharePhoto = [CCMenuItemFont itemFromString:@"SharePhoto" 
                                                                  block:^(id sender){
                                                                      SinaHelper *sina = [[SinaHelper alloc] init];
                                                                      sina.message = @"hello this is a share photo test";
                                                                      sina.imageName = @"oldMan.png";
                                                                      [sina sharePhoto];
                                                                  }];
        sinaSharePhoto.color = ccRED;
        CCMenuItemFont *renrenSharePhoto = [CCMenuItemFont itemFromString:@"SharePhoto" 
                                                                    block:^(id sender){
                                                                        RenRenHelper *renren = [[RenRenHelper alloc] init];
                                                                        renren.message = @"hello this is a share photo test";
                                                                        renren.imageName = @"oldMan.png";
                                                                        [renren sharePhoto];
                                                                    }];
        renrenSharePhoto.color = ccGREEN;
        CCMenuItemFont *qqSharePhoto = [CCMenuItemFont itemFromString:@"SharePhoto" 
                                                                block:^(id sender){
                                                                    QQHelper *qq = [[QQHelper alloc] init];
                                                                    qq.message = @"hello this is a share photo test";
                                                                    qq.imageName = @"oldMan.png";
                                                                    [qq sharePhoto];
                                                                }];
        qqSharePhoto.color = ccBLUE;
        CCMenuItemFont *twitterSharePhoto = [CCMenuItemFont itemFromString:@"SharePhoto" 
                                                                     block:^(id sender){
                                                                         TwitterHelper *tw = [[TwitterHelper alloc] init];
                                                                         tw.message = @"hello this is a share photo test";
                                                                         tw.imageName = @"oldMan.png";
                                                                         [tw sharePhoto];
                                                                     }];
        twitterSharePhoto.color = ccMAGENTA;
        CCMenuItemFont *facebookSharePhoto = [CCMenuItemFont itemFromString:@"SharePhoto" 
                                                                      block:^(id sender){
                                                                          FBHelper *fb = [[FBHelper alloc] init];
                                                                          fb.message = @"hello this is a share photo test";
                                                                          fb.imageName = @"oldMan.png";
                                                                          [fb sharePhoto];
                                                                      }];
        facebookSharePhoto.color = ccYELLOW;
        
        CCMenu *menu2 = [CCMenu menuWithItems:sinaSharePhoto,renrenSharePhoto,qqSharePhoto,twitterSharePhoto,facebookSharePhoto, nil];
        menu2.position = ccp(300,180);
        [menu2 alignItemsVerticallyWithPadding:10];
        [self addChild:menu2];
        
        CCMenuItemFont *mailSharePhoto = [CCMenuItemFont itemFromString:@"sendMail" 
                                                                  block:^(id sender){
                                                                      MailHelper *mail = [[MailHelper alloc] init];
                                                                      [mail sendmail:@"share Photo" 
                                                                                body:@"hello this is a share photo test" 
                                                                           imageName:@"oldMan.png"];
                                                                  }];
        CCMenu *menu3 = [CCMenu menuWithItems:mailSharePhoto, nil];
        menu3.position = ccp(200,80);
        [menu3 alignItemsVerticallyWithPadding:10];
        [self addChild:menu3];
        
    }
    return self;
}

- (void) displayLoadingLayer{
    LoadingLayer *layer = [[LoadingLayer alloc] initText:@"上传图片中......"];
    [self addChild:layer z:10 tag:10];
    [layer release];
}

- (void) closeLoadingLayer{
    LoadingLayer *layer = (LoadingLayer *)[self getChildByTag:10];
    [layer clearIndicator];
    [layer removeFromParentAndCleanup:YES];
}

@end
