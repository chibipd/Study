//
//  KINWebBrowserViewController.m
//
//  KINWebBrowser
//
//  Created by David F. Muir V
//  dfmuir@gmail.com
//  Co-Founder & Engineer at Kinwa, Inc.
//  http://www.kinwa.co
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 David Muir
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "HYMeituanViewController.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "HYNavigationController.h"
#import "HYEarnCashTicketAlertView.h"
#import "HYGetProtocolReq.h"
#import "HYUserInfo.h"
#import "HYMovieGetURLRequest.h"
#import "METoast.h"


static void *KINContext = &KINContext;

@interface HYMeituanViewController ()
{
    HYGetProtocolReq *_getProtocolReq;// 说明文字请求
    HYMovieGetURLRequest *_movieURLRequest;
}

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *stopButton, *actionButton, *fixedSeparator, *flexibleSeparator;
@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, strong) UIPopoverController *actionPopoverController;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;
@property (nonatomic, strong) UIBarButtonItem *leftBarItemBar;

@property (nonatomic, strong) HYEarnCashTicketAlertView *alertV;

@end

@implementation HYMeituanViewController

#pragma mark - Static Initializers

+ (HYMeituanViewController *)webBrowser {
    HYMeituanViewController *webBrowserViewController = [HYMeituanViewController webBrowserWithConfiguration:nil];
    return webBrowserViewController;
}

+ (HYMeituanViewController *)webBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    HYMeituanViewController *webBrowserViewController = [[HYMeituanViewController alloc] initWithConfiguration:configuration];
    return webBrowserViewController;
}

+ (UINavigationController *)navigationControllerWithWebBrowser {
    HYMeituanViewController *webBrowserViewController = [[HYMeituanViewController alloc] initWithConfiguration:nil];
    return [HYMeituanViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithWebBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    HYMeituanViewController *webBrowserViewController = [[HYMeituanViewController alloc] initWithConfiguration:configuration];
    return [HYMeituanViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithBrowser:(HYMeituanViewController *)webBrowser {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowser action:@selector(doneButtonPressed:)];
    [webBrowser.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    return navigationController;
}

#pragma mark - Initializers

- (id)init {
    return [self initWithConfiguration:nil];
}

- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    if(self) {
        
        self.uiWebView = [[UIWebView alloc] init];
        /*
        if([WKWebView class]) {
            if(configuration) {
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            }
            else {
                self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
            }
        }
        else {
            self.uiWebView = [[UIWebView alloc] init];
        }
         */
        
        self.actionButtonHidden = NO;
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
        self.leftItemType = CustomItemBar;
        
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HYEarnCashTicketAlertView *alertV = [[HYEarnCashTicketAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _alertV = alertV;
    [alertV.agreedBtn addTarget:self action:@selector(cancelAlert:) forControlEvents:UIControlEventTouchUpInside];
    [alertV show];
    
    [self getProtocolDetail];
    
    if (self.type == MovieTicket)
    {
        [self getMovieURL];
    }
    
    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    
    if(self.wkWebView)
    {
        [self.wkWebView setFrame:self.view.bounds];
        [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.wkWebView setNavigationDelegate:self];
        [self.wkWebView setMultipleTouchEnabled:YES];
        [self.wkWebView setAutoresizesSubviews:YES];
        [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.wkWebView];
        
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:KINContext];
    }
    else if(self.uiWebView) {
        [self.uiWebView setFrame:self.view.bounds];
        [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.uiWebView setDelegate:self];
        [self.uiWebView setMultipleTouchEnabled:YES];
        [self.uiWebView setAutoresizesSubviews:YES];
        [self.uiWebView setScalesPageToFit:YES];
        [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.uiWebView];
    }
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    self.navigationItem.leftBarButtonItem = self.leftBarItemBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    
//    [self updateToolbarState];
    
    if ([self.navigationController isKindOfClass:[HYNavigationController class]])
    {
        HYNavigationController *nav = (HYNavigationController *)self.navigationController;
        [nav setEnableSwip:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    
//    [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    
    [self.uiWebView setDelegate:nil];
    [self.progressView removeFromSuperview];
    
    if ([self.navigationController isKindOfClass:[HYNavigationController class]])
    {
        HYNavigationController *nav = (HYNavigationController *)self.navigationController;
        [nav setEnableSwip:YES];
    }
}

#pragma mark - privateMethod
- (void)getMovieURL
{
    if (!_movieURLRequest)
    {
        _movieURLRequest = [[HYMovieGetURLRequest alloc] init];
    }
    
    [HYLoadHubView show];
    WS(weakSelf);
    [_movieURLRequest sendReuqest:^(id result, NSError *error)
     {
         [HYLoadHubView dismiss];
         if ([result isKindOfClass:[HYMovieGetURLResponse class]]) {
             HYMovieGetURLResponse *resp = (HYMovieGetURLResponse *)result;
             if (resp.status == 200)
             {
                 NSString *url = [resp.URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                 [weakSelf loadURL:[NSURL URLWithString:url]];
             }
             else
             {
                 [METoast toastWithMessage:resp.suggestMsg];
             }
         }
     }];
}

- (void)getProtocolDetail
{
    if (!_getProtocolReq)
    {
        _getProtocolReq = [[HYGetProtocolReq alloc] init];
    }
    
    if (self.type == Meituan)
    {
        _getProtocolReq.copywriting_key = @"meituan_tips";
    }
    else if (self.type == MovieTicket)
    {
        _getProtocolReq.copywriting_key = @"maizuo_tips";
    }
    
    
    [HYLoadHubView show];
    __weak typeof(self) bself = self;
    [_getProtocolReq sendReuqest:^(id result, NSError *error) {
        
        [HYLoadHubView dismiss];
        NSString *content = nil;
        if ([result isKindOfClass:[HYGetProtocolResp class]])
        {
            HYGetProtocolResp *resp = (HYGetProtocolResp *)result;
            content = resp.resTips;
        }
        
        if (!error)
        {
            [bself.alertV.contentWebV loadHTMLString:content
                                             baseURL:nil];
        }
    }];
}

#pragma mark setter/getter
- (UIBarButtonItem *)leftBarItemBar
{
    if (!_leftBarItemBar)
    {
        UIView *leftBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
        
        UIImage *goBack = [UIImage imageNamed:@"nav_back_itembar"];
        UIButton *goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        goBackBtn.frame = CGRectMake(0, 0, 40, 44);
        [goBackBtn setImage:goBack forState:UIControlStateNormal];
        [goBackBtn setAdjustsImageWhenHighlighted:NO];
        [goBackBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [goBackBtn addTarget:self
                      action:@selector(goBack:)
            forControlEvents:UIControlEventTouchUpInside];
        [leftBarView addSubview:goBackBtn];
        
        UIImage *close = [UIImage imageNamed:@"icon_close"];
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(40, 0, 40, 44);
        [closeBtn setImage:close forState:UIControlStateNormal];
        [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        [closeBtn setAdjustsImageWhenHighlighted:NO];
        
        [closeBtn addTarget:self
                     action:@selector(closeWeb:)
           forControlEvents:UIControlEventTouchUpInside];
        [leftBarView addSubview:closeBtn];
        
        _leftBarItemBar = [[UIBarButtonItem alloc] initWithCustomView:leftBarView];
    }
    
    return _leftBarItemBar;
}

#pragma mark - overload
- (void)goBack:(id)sender
{
    if(self.wkWebView && [self.wkWebView canGoBack])
    {
        [self.wkWebView goBack];
    }
    else if(self.uiWebView && [self.uiWebView canGoBack])
    {
        [self.uiWebView goBack];
    }
    else
    {
        [self closeWeb:sender];
    }
}

- (void)closeWeb:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)backToRootViewController:(id)sender
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

#pragma mark - Public Interface

- (void)loadURL:(NSURL *)URL {
    if(self.wkWebView) {
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:URL]];
    }
    else if(self.uiWebView) {
        [self.uiWebView loadRequest:[NSURLRequest requestWithURL:URL]];
    }
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self.progressView setTintColor:tintColor];
    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.toolbar setTintColor:tintColor];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    [self.navigationController.navigationBar setBarTintColor:barTintColor];
    [self.navigationController.toolbar setBarTintColor:barTintColor];
}

- (void)setActionButtonHidden:(BOOL)actionButtonHidden {
    _actionButtonHidden = actionButtonHidden;
    [self updateToolbarState];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
        self.uiWebViewCurrentURL = request.URL;
        self.uiWebViewIsLoading = YES;
        [self updateToolbarState];
        
        [self fakeProgressViewStartLoading];
        
        if([self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
            [self.delegate webBrowser:self didStartLoadingURL:request.URL];
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            
            [self fakeProgressBarStopLoading];
        }
        
        if([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)]) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.uiWebView.request.URL];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            
            [self fakeProgressBarStopLoading];
        }
        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.uiWebView.request.URL error:error];
        }
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        if([self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
            [self.delegate webBrowser:self didStartLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        if([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)]) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

#pragma mark - Toolbar State

- (void)updateToolbarState {
    
    BOOL canGoBack = self.wkWebView.canGoBack || self.uiWebView.canGoBack;
    BOOL canGoForward = self.wkWebView.canGoForward || self.uiWebView.canGoForward;
    
    [self.backButton setEnabled:canGoBack];
    [self.forwardButton setEnabled:canGoForward];
    
    if(!self.backButton) {
        [self setupToolbarItems];
    }
    
    NSArray *barButtonItems;
    if(self.wkWebView.loading || self.uiWebViewIsLoading) {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.stopButton, self.flexibleSeparator];
        
        if(self.showsURLInNavigationBar) {
            NSString *URLString;
            if(self.wkWebView) {
                URLString = [self.wkWebView.URL absoluteString];
            }
            else if(self.uiWebView) {
                URLString = [self.uiWebViewCurrentURL absoluteString];
            }
            
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length]-1];
            self.navigationItem.title = URLString;
        }
    }
    else {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.refreshButton, self.flexibleSeparator];
        
        if(self.showsPageTitleInNavigationBar) {
            if(self.wkWebView) {
                self.navigationItem.title = self.wkWebView.title;
            }
            else if(self.uiWebView) {
                self.navigationItem.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
            }
        }
    }
    
    if(!self.actionButtonHidden) {
        NSMutableArray *mutableBarButtonItems = [NSMutableArray arrayWithArray:barButtonItems];
        [mutableBarButtonItems addObject:self.actionButton];
        barButtonItems = [NSArray arrayWithArray:mutableBarButtonItems];
    }
    
    [self setToolbarItems:barButtonItems animated:YES];
}

- (void)setupToolbarItems {
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    self.fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.fixedSeparator.width = 50.0f;
    self.flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#pragma mark - Done Button Action

- (void)doneButtonPressed:(id)sender {
    [self dismissAnimated:YES];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)backButtonPressed:(id)sender {
    
    if(self.wkWebView) {
        [self.wkWebView goBack];
    }
    else if(self.uiWebView) {
        [self.uiWebView goBack];
    }
//    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView goForward];
    }
    else if(self.uiWebView) {
        [self.uiWebView goForward];
    }
//    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView stopLoading];
        [self.wkWebView reload];
    }
    else if(self.uiWebView) {
        [self.uiWebView stopLoading];
        [self.uiWebView reload];
    }
}

- (void)stopButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView stopLoading];
    }
    else if(self.uiWebView) {
        [self.uiWebView stopLoading];
    }
}

- (void)actionButtonPressed:(id)sender {
    NSURL *URLForActivityItem;
    if(self.wkWebView) {
        URLForActivityItem = self.wkWebView.URL;
    }
    else if(self.uiWebView) {
        URLForActivityItem = self.uiWebView.request.URL;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
        ARChromeActivity *chromeActivity = [[ARChromeActivity alloc] init];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[URLForActivityItem] applicationActivities:@[safariActivity, chromeActivity]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if(self.actionPopoverController) {
                [self.actionPopoverController dismissPopoverAnimated:YES];
            }
            self.actionPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
            [self.actionPopoverController presentPopoverFromBarButtonItem:self.actionButton permittedArrowDirections: UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [self presentViewController:controller animated:YES completion:NULL];
        }
    });
}


#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Fake Progress Bar Control (UIWebView)

- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.fakeProgressTimer) {
        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)fakeProgressBarStopLoading {
    if(self.fakeProgressTimer) {
        [self.fakeProgressTimer invalidate];
    }
    
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)fakeProgressTimerDidFire:(id)sender {
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.uiWebView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

/**
 * 取消弹窗提示
 */
- (void)cancelAlert:(UIButton *)btn
{
    [_alertV dismiss];
}

#pragma mark - Interface Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.uiWebView setDelegate:nil];
    
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    
    [HYLoadHubView dismiss];
    
    [_getProtocolReq cancel];
    _getProtocolReq = nil;
    
    [_movieURLRequest cancel];
    _movieURLRequest = nil;
}


@end

@implementation UINavigationController(KINWebBrowser)

- (HYMeituanViewController *)rootWebBrowser {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return (HYMeituanViewController *)rootViewController;
}

@end
