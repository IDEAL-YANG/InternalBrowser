//
//  ViewController.m
//  InternalBrowser
//
//  Created by ideal on 2016/7/7.
//  Copyright © 2016年 New Idea. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WKWebView.h>

#define kUrl @"https://www.cmall.com/page/CN/provision.html"//https://www.cmall.com/page/CN/activity/Iron_Lady.html?clientType=ios"

@interface ViewController ()

@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) CALayer *progressLayer;

@property (strong, nonatomic) UILabel *hostLabel;

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
    
    self.url = [NSURL URLWithString:kUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [(WKWebView *)self.view removeObserver:self forKeyPath:@"estimatedProgress"];
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
                self.hostLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", self.url.host];
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
