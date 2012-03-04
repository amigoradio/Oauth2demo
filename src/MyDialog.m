//
//  MyDialog.m
//  testOauth2
//
//  Created by radio on 12-2-3.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "MyDialog.h"
#import "Facebook.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};

static CGFloat kTransitionDuration = 0.3;

static CGFloat kPadding = 0;
static CGFloat kBorderWidth = 10;

///////////////////////////////////////////////////////////////////////////////////////////////////

static BOOL FBIsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MyDialog

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    if (radius == 0) {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
    } else {
        rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
        CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    if (fillColors) {
        CGContextSaveGState(context);
        CGContextSetFillColor(context, fillColors);
        if (radius) {
            [self addRoundedRectToPath:context rect:rect radius:radius];
            CGContextFillPath(context);
        } else {
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    
    CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 1.0);
    
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y-0.5},
            {rect.origin.x+rect.size.width, rect.origin.y-0.5}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5},
            {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+rect.size.width-0.5, rect.origin.y},
            {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y},
            {rect.origin.x+0.5, rect.origin.y+rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(space);
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == _orientation) {
        return NO;
    } else {
        return orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown
        || orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight;
    }
}

- (CGAffineTransform)transformForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (void)sizeToFitOrientation:(BOOL)transform {
    if (transform) {
        self.transform = CGAffineTransformIdentity;
    }
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(
                                 frame.origin.x + ceil(frame.size.width/2),
                                 frame.origin.y + ceil(frame.size.height/2));
    
    CGFloat scale_factor = 1.0f;
    if (FBIsDeviceIPad()) {
        // On the iPad the dialog's dimensions should only be 60% of the screen's
        scale_factor = 0.6f;
    }
    
    CGFloat width = floor(scale_factor * frame.size.width) - kPadding * 2;
    CGFloat height = floor(scale_factor * frame.size.height) - kPadding * 2;
    
    _orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        self.frame = CGRectMake(kPadding, kPadding, height, width);
    } else {
        self.frame = CGRectMake(kPadding, kPadding, width, height);
    }
    self.center = center;
    
    if (transform) {
        self.transform = [self transformForOrientation];
    }
}

- (void)updateWebOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.setAttribute('orientation', 90);"];
    } else {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.removeAttribute('orientation');"];
    }
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params) {
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator) {
            NSString* value = [params objectForKey:key];
            NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL, /* allocator */
                                                                                          (CFStringRef)value,
                                                                                          NULL, /* charactersToLeaveUnescaped */
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
            [escaped_value release];
        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)postDismissCleanup {
    [self removeObservers];
    [self removeFromSuperview];
    [_modalBackgroundView removeFromSuperview];
}

- (void)dismiss:(BOOL)animated {
    [self dialogWillDisappear];
    
    [_loadingURL release];
    _loadingURL = nil;
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
        self.alpha = 0;
        [UIView commitAnimations];
    } else {
        [self postDismissCleanup];
    }
}

- (void)cancel {
    [self dismiss:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
    if ((self = [super initWithFrame:CGRectZero])) {
        _loadingURL = nil;
        _showingKeyboard = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(kPadding, kPadding, 480, 480)];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_webView];
        
        UIImage* closeImage = [UIImage imageNamed:@"close.png"];
        
        UIColor* color = [UIColor colorWithRed:167.0/255 green:184.0/255 blue:216.0/255 alpha:1];
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_closeButton setImage:closeImage forState:UIControlStateNormal];
        [_closeButton setTitleColor:color forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(cancel)
               forControlEvents:UIControlEventTouchUpInside];
        
        // To be compatible with OS 2.x
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_2_2
        _closeButton.font = [UIFont boldSystemFontOfSize:12];
#else
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
#endif
        
        _closeButton.showsTouchWhenHighlighted = YES;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_closeButton];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                    UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_spinner];
        _modalBackgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void)dealloc {
    _webView.delegate = nil;
    [_webView release];
    [_params release];
    [_serverURL release];
    [_spinner release];
    [_closeButton release];
    [_loadingURL release];
    [_modalBackgroundView release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
    [self drawRect:rect fill:kBorderGray radius:0];
    
    CGRect webRect = CGRectMake(
                                ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth)+1,
                                rect.size.width - kBorderWidth*2, _webView.frame.size.height+1);
    
    [self strokeLines:webRect stroke:kBorderBlack];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSURL *url = [request URL];
    //NSLog(@"shouldStartLoadWithRequest url=%@",url);
    if (_isTwitter) {
        if ([_delegate respondsToSelector:@selector(backFromBrowser:)]) {
            if ([_delegate backFromBrowser:url]) {
                [self dismiss:YES];
                return NO;
            }
        }
    }else{
        NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
        //NSLog(@"array=%@",array);
        if ([array count]>1) {
            NSString *params = [array objectAtIndex:1];
            if ([params length] > 0) {
                NSRange token = [params rangeOfString:@"access_token"];
                if (token.location != NSNotFound) {
                    if ([_delegate respondsToSelector:@selector(dialogDidSucceed:)]) {
                        [_delegate dialogDidSucceed:url];
                    }
                    [self dismiss:YES];
                }
                NSRange error = [params rangeOfString:@"error_code"];
                if (error.location != NSNotFound) {
                    if ([_delegate respondsToSelector:@selector(dismissWithUrl:)]) {
                        [_delegate dismissWithUrl:url];
                    }
                    [self dismiss:YES];
                }
                return NO;
            }
        }
    }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    //NSLog(@"webViewDidFinishLoad");
    [self updateWebOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!(([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -999) ||
          ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
        //NSLog(@"didFailLoadWithError=%@",error);
        [self dismiss:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
        [self updateWebOrientation];
        
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [self sizeToFitOrientation:YES];
        [UIView commitAnimations];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
    
    _showingKeyboard = YES;
    
    if (FBIsDeviceIPad()) {
        // On the iPad the screen is large enough that we don't need to
        // resize the dialog to accomodate the keyboard popping up
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _webView.frame = CGRectInset(_webView.frame,
                                     -(kPadding + kBorderWidth),
                                     -(kPadding + kBorderWidth));
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _showingKeyboard = NO;
    
    if (FBIsDeviceIPad()) {
        return;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _webView.frame = CGRectInset(_webView.frame,
                                     kPadding + kBorderWidth,
                                     kPadding + kBorderWidth);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

/**
 * Find a specific parameter from the url
 */
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}

- (id)initWithURL: (NSString *) serverURL
           params: (NSMutableDictionary *) params 
         delegate: (id <MyDialogDelegate>) delegate 
    webViewFlag: (BOOL) isTwitter{
    
    self = [self init];
    _serverURL = [serverURL retain];
    _params = [params retain];
    _delegate = delegate;
    _isTwitter = isTwitter;
    return self;
}

- (void)loadURL:(NSString*)url get:(NSDictionary*)getParams {
    [_loadingURL release];
    _loadingURL = [[self generateURL:url params:getParams] retain];
    //NSLog(@"_loadingURL=%@",_loadingURL);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
    [_webView loadRequest:request];
}

- (void)showDialog {
    [self loadURL:_serverURL get:_params];
    [self sizeToFitOrientation:NO];
    
    CGFloat innerWidth = self.frame.size.width - (kBorderWidth+1)*2;
    [_closeButton sizeToFit];
    
    _closeButton.frame = CGRectMake(
                                    2,
                                    2,
                                    29,
                                    29);
    
    _webView.frame = CGRectMake(
                                kBorderWidth+1,
                                kBorderWidth+1,
                                innerWidth,
                                self.frame.size.height - (1 + kBorderWidth*2));
    
    [_spinner sizeToFit];
    [_spinner startAnimating];
    _spinner.center = _webView.center;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    _modalBackgroundView.frame = window.frame;
    [_modalBackgroundView addSubview:self];
    [window addSubview:_modalBackgroundView];
    
    [window addSubview:self];
    
    [self dialogWillAppear];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    [self addObservers];
}

- (void)dialogWillAppear {
}

- (void)dialogWillDisappear {
}

@end

