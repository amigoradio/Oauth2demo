//
//  LoadingLayer.h
//  HitFace
//
//  Created by cheng gong on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LoadingLayer : CCLayerColor{
    UIActivityIndicatorView *indicator;
}

- (id) initText:(NSString *) text;
- (void) clearIndicator;

@end
