//
//  MyDialog.h
//  testOauth2
//
//  Created by radio on 12-2-3.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MyDialogDelegate;

@interface MyDialog : UIView <UIWebViewDelegate> {
    id<MyDialogDelegate> _delegate;
    NSMutableDictionary *_params;
    NSString * _serverURL;
    NSURL* _loadingURL;
    UIWebView* _webView;
    UIActivityIndicatorView* _spinner;
    UIButton* _closeButton;
    UIInterfaceOrientation _orientation;
    BOOL _showingKeyboard;
    UIView* _modalBackgroundView;
    BOOL _isTwitter;
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle;

- (id)initWithURL: (NSString *) loadingURL
           params: (NSMutableDictionary *) params 
            delegate: (id <MyDialogDelegate>) delegate
            webViewFlag: (BOOL) isTwitter;
- (void)showDialog;
- (void)loadURL:(NSString*)url
            get:(NSDictionary*)getParams;
- (void)dialogWillAppear;
- (void)dialogWillDisappear;
@end

@protocol MyDialogDelegate <NSObject>

@optional
- (void)dialogDidSucceed:(NSURL *)url;
- (void)dismissWithUrl:(NSURL *)url;
- (BOOL)backFromBrowser:(NSURL*)url;
@end
