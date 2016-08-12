//
//  ViewController.m
//  InternalBrowser
//
//  Created by ideal on 2016/7/7.
//  Copyright © 2016年 New Ideal. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

#define kUrl @"http://www.cmall.com/page/CN/activity/amazingjianghu.html?clientType=ios"

@interface ViewController ()<WKNavigationDelegate>

@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) CALayer *progressLayer;

@property (strong, nonatomic) UILabel *hostLabel;

@property WKWebViewJavascriptBridge* bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.hostLabel];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self.progressView.layer addSublayer:self.progressLayer];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    // 开启日志，方便调试
//    [WKWebViewJavascriptBridge enableLogging];
    [self.bridge setWebViewDelegate:self];
    
    [self.bridge callHandler:@"OC_Call_JS_Methods" data:@{@"OC_Data":@"I come form OC"} responseCallback:^(id responseData) {
        NSLog(@"OC_Call_JS_Methods_Back,receive JS Data:%@",responseData);
    }];
    [self.bridge registerHandler:@"goToDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"goToDetail called: %@", data);
        responseCallback(@"Response from OC");
    }];
    
//    self.url = [NSURL URLWithString:kUrl];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
//    [self.webView loadRequest:request];
    
    [self loadHtml];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bridge setWebViewDelegate:nil];
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"-----内存释放了");
}

- (void)loadHtml{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ThirdJSExample" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    self.url = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:appHtml baseURL:self.url];
}

#pragma mark -

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
    if (!self.title) {
        __weak typeof(ViewController) *weakSelf = self;
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
            weakSelf.title = value;
        }];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}


#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) {
            return;
        }
        
        self.progressLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], 3);
        if ([change[@"new"] floatValue] == 1) {
            __weak typeof(ViewController) *weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progressLayer.opacity = 0;
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.progressLayer.frame = CGRectMake(0, 0, 0, 3);
                weakSelf.hostLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", weakSelf.url.host];
            });
        }
    }
}

#pragma mark -

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [_webView.scrollView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    return _webView;
}

- (UIView *)progressView{
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 3)];
        _progressView.backgroundColor = [UIColor clearColor];
    }
    return _progressView;
}

- (CALayer *)progressLayer{
    if (!_progressLayer) {
        _progressLayer = [CALayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 0, 3);
        _progressLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    return _progressLayer;
}

- (UILabel *)hostLabel{
    if (!_hostLabel) {
        _hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 30)];
        _hostLabel.textAlignment = NSTextAlignmentCenter;
        _hostLabel.font = [UIFont systemFontOfSize:14];
    }
    return _hostLabel;
}

@end
