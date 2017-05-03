//
//  ViewController.m
//  UIWebviewDemo
//
//  Created by shange on 2017/4/11.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

/**
 *  属性说明
 */
@property(nonatomic,strong) UIWebView *myWebview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.myWebview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.myWebview.delegate =self;
    [self loadBaidu];
//    [self loadLocalHostHtml];
//    [self loadHtmlWithString];
    
    
    
[self.view addSubview:self.myWebview];
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, 600, 100, 50);
    button.backgroundColor =[UIColor redColor];
    [button addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"reload" forState:0];
    [self.view addSubview:button];
    
    UIButton *button1 =[UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(160, 600, 100, 50);
    button1.backgroundColor =[UIColor redColor];
    [button1 addTarget:self action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"stopLoading" forState:0];
    [self.view addSubview:button1];
    
    UIButton *button2 =[UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(270, 600, 100, 50);
    button2.backgroundColor =[UIColor redColor];
    [button2 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"goBack" forState:0];
    [self.view addSubview:button2];


}
/**   
 *-(void)loadRequest:(NSURLRequest *)request 方法即可以去通过网络连接加载html资源，也可以去加载本地的html资源
 **/
#pragma mark  加载网络的html
-(void) loadBaidu
{
    //    加载网络html
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lol.qq.com"]];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.163.com"]];
    [self.myWebview loadRequest:request];
    
    self.myWebview.scalesPageToFit = YES;    // 是否允许用户对网页进行缩放,yes是允许
    self.myWebview.dataDetectorTypes =  UIDataDetectorTypePhoneNumber;  // 检测网站中电话号码
    self.myWebview.allowsInlineMediaPlayback = YES;                //设置是否使用内联播放器播放视频
    self.myWebview.mediaPlaybackRequiresUserAction = true;   //设置视频是否自动播放
    self.myWebview.mediaPlaybackAllowsAirPlay = true;            //设置音频播放是否支持ari play功能
    self.myWebview.suppressesIncrementalRendering = true;         //设置是否将数据加载如内存后渲染界面
    self.myWebview.keyboardDisplayRequiresUserAction = YES;  //设置用户交互模式
//            self.myWebview.paginationMode = UIWebPaginationModeLeftToRight; //当网页的大小超出view时，将网页以翻页的效果展示
    //        self.myWebview.pageLength = 400;
    self.myWebview.allowsPictureInPictureMediaPlayback = YES; //是否允许画中画播放,目前ipad支持iPhone不支持
    self.myWebview.allowsLinkPreview = YES; //长按链接是否支持预览（支持3D Touch的设备）
    self.myWebview.scrollView.bounces = false;  //禁用页面滚动弹跳
    //      移除外部的阴影
    self.myWebview.scrollView.backgroundColor = [UIColor redColor];
    self.myWebview.paginationBreakingMode = UIWebPaginationBreakingModeColumn;
    /*
     UIWebPaginationBreakingModePage,//默认设置是这个属性，CSS属性以页样式
     UIWebPaginationBreakingModeColumn//当UIWebPaginationBreakingMode设置这个属性的时候，这个页面内容CSS属性以column-break 代替page-breaking样式
     */
    UIScrollView *scrollView = self.myWebview.scrollView;
    for (int i = 0; i < scrollView.subviews.count ; i++)
    {
        UIView *view = [scrollView.subviews objectAtIndex:i];
        if ([view isKindOfClass:[UIImageView class]])
        {
            view.hidden = YES ;
        }
    }
    
    
}
#pragma mark 加载本地的html
-(void)loadLocalHostHtml
{
    NSURL *path = [[NSBundle mainBundle]URLForResource:@"Sample" withExtension:@"html"];
    NSURLRequest *request =[NSURLRequest requestWithURL:path];
        [self.myWebview loadRequest:request];

}
/*
* -(void)loadHTMLString:(NSString )string baseURL:(nullable NSURL )baseURL 方法一般用来加载本地的html界面。
 **/
#pragma mark 加载本地的html
-(void)loadHtmlWithString
{
//    加载css
    NSURL *cssPath = [[NSBundle mainBundle]URLForResource:@"ShareSDK" withExtension:@"css"];
//    创建css标签
    NSString *css = [NSString stringWithFormat:@"<link href =\"%@\" rel = %@>",cssPath,@"\"stylesheet\""];
    NSLog(@"--css--%@",css);
    NSString *html =[NSString stringWithFormat:@"<html><head>%@</head><body><p>网页中的文字</p> <button id=\"login\" onclick=\"login()\">点击按钮</button> <img src=\"%@\" alt="">   </body></html>",css,css];
    [self.myWebview loadHTMLString:html baseURL:nil];
}
#pragma mark 代理
//代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    /**返回YES，进行加载。通过UIWebViewNavigationType可以得到请求发起的原因
     如果为webView添加了delegate对象并实现该接口，那么在webView加载任何一个frame之前都会delegate对象的该方法，该方法的返回值用以控制是否允许加载目标链接页面的内容，返回YES将直接加载内容，NO则反之。并且UIWebViewNavigationType枚举，定义了页面中用户行为的分类，包括;
     UIWebViewNavigationTypeLinkClicked，0 用户触击了一个链接。
     UIWebViewNavigationTypeFormSubmitted，1 用户提交了一个表单。
     UIWebViewNavigationTypeBackForward，2, 用户触击前进或返回按钮。
     UIWebViewNavigationTypeReload，3, 用户触击重新加载的按钮。
     UIWebViewNavigationTypeFormResubmitted，4,用户重复提交表单
     UIWebViewNavigationTypeOther，5, 发生其它行为。
     */
//    NSLog(@"----request-------%@",request);
    NSLog(@"----navigationType-------%ld",(long)navigationType);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //开始加载，可以加上风火轮（也叫菊花）
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //完成加载
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //加载出错
}
#pragma mark buttond的点击方法
- (void) reload
{
    NSLog(@"button");
    [self.myWebview reload];
}
- (void ) stopLoading
{
    [self.myWebview stopLoading];
}
- (void) goBack
{
    [self.myWebview goBack];
}








@end
