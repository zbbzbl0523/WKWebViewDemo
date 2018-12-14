//
//  ViewController.m
//  JavaScriptCoreDemo
//
//  Created by z.bl on 2018/12/13.
//  Copyright © 2018 helloworld. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define kScreenWidth            [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight           [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *myWebView;
@property (nonatomic,strong) WKWebViewConfiguration *myWebViewConfig;

@end

@implementation ViewController
#pragma mark Lazy-load
- (WKWebView *)myWebView{
    if (!_myWebView) {
        _myWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) configuration:self.myWebViewConfig];
        _myWebView.UIDelegate = self;
        _myWebView.navigationDelegate = self;
    }
    return _myWebView;
}

- (WKWebViewConfiguration *)myWebViewConfig{
    if (!_myWebViewConfig) {
        _myWebViewConfig = [[WKWebViewConfiguration alloc] init];
    }
    return _myWebViewConfig;
}

#pragma mark VC生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewOnScreen];
    [self webViewLoadHTMLSource];
    [self handleJSFunction];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark 添加各种UI元素
- (void)addWebViewOnScreen {
    [self.view addSubview:self.myWebView];
}

#pragma mark webView加载页面
- (void)webViewLoadHTMLSource {
    NSString *htmlSourcePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlSourceString = [NSString stringWithContentsOfFile:htmlSourcePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [[NSBundle mainBundle] bundleURL];
    
    //此为加载本地HTML的方式，如果需要加载网络HTML资源，可以选择下面loadFileURL的方法
    //[self.myWebView loadFileURL:(nonnull NSURL *) allowingReadAccessToURL:(nonnull NSURL *)]
    [self.myWebView loadHTMLString:htmlSourceString baseURL:baseUrl];
}

#pragma mark 添加在native端注册JS方法
//以便处理调用
- (void)handleJSFunction {
    WKUserContentController *userCC = _myWebViewConfig.userContentController;
    [userCC addScriptMessageHandler:self name:@"loginPress"];
    [userCC addScriptMessageHandler:self name:@"registerPress"];
}

#pragma mark WKNavigationDelegate
// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面开始加载");
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"页面内容开发返回");
}

// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载完成了");
}

// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载失败");
}

#pragma mark WKUIDelegate
//这个是调起系统的alart
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"调用alert时的message - %@",message);
    
    if ([message isEqualToString:@"login"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"登录询问" message:@"是否需要登录？" preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self performSelector:@selector(loginSuccessCallBack) withObject:nil afterDelay:2];
                                                                  completionHandler();
                                                              }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 completionHandler();
                                                             }];
        
        [alert addAction:cancelAction];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if ([message isEqualToString:@"loginSuccess"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"登录提示" message:@"登录成功!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"知道了"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  completionHandler();
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if ([message isEqualToString:@"registerSuccess"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注册提示" message:@"注册成功!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"知道了"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  completionHandler();
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
}

#pragma mark WKScriptMessageHandler协议方法
//handle html页面处理事件
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"loginPress"]) {
        NSLog(@"触发native登录事件");
        //在此处可以处理native登录事件，怎么样都可以
        
        [self performSelector:@selector(loginSuccessCallBack) withObject:nil afterDelay:2];
    }
    if ([message.name isEqualToString:@"registerPress"]) {
        NSLog(@"触发native注册事件");
        //在此处可以处理native注册事件，怎么样都可以
        [self performSelector:@selector(registerSuccessCallBack) withObject:nil afterDelay:2];
    }
}

#pragma mark constmerFunc
- (void)loginSuccessCallBack {
    NSString *loginSuccessCallbackString = [NSString stringWithFormat:@"loginSuccessCallBack('%@')",@"loginSuccess"];
    [self.myWebView evaluateJavaScript:loginSuccessCallbackString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"if have error %@",error);
    }];
}

- (void)registerSuccessCallBack {
    NSString *loginSuccessCallbackString = [NSString stringWithFormat:@"loginSuccessCallBack('%@')",@"registerSuccess"];
    [self.myWebView evaluateJavaScript:loginSuccessCallbackString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"if have error %@",error);
    }];
}

@end
