//
//  ViewController.m
//  JSShare
//
//  Created by shange on 2017/4/8.
//  Copyright © 2017年 shange. All rights reserved.
//

#import "ViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//微信SDK头文件
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <MOBFoundation/MOBFoundation.h>

#import <AJSFoundation/AJSJson.h>
#import <AJSFoundation/AJSURL.h>

@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Sample" ofType:@"html"];
    NSURL*htmlURL = [NSURL fileURLWithPath:path];
    self.webView =[[UIWebView alloc]initWithFrame:self.view.bounds];
    NSURLRequest *request =[NSURLRequest requestWithURL:htmlURL];
    [_webView loadRequest:request];
    _webView.delegate = self;
    [self.view addSubview:_webView];

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self analyzeURL:request.URL];
    [self share:request.URL];
    [self longin:request.URL];
//    传递数据对象类型的测试
    [self textLoadJson:request.URL];
    return YES;
}

// 在此方法中调用将无效
-(void)webViewDidStartLoad:(UIWebView *)webView
{
  [self.webView stringByEvaluatingJavaScriptFromString:@"window.$sharesdk.ajsTest()"];
}
// 网页完成加载
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
//    注意stringByEvaluatingJavaScriptFromString必须保证是在主线线程中完成任务
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.$sharesdk.initSDK()"];
    NSLog(@"----1------%@",[NSThread currentThread]);   //线程是1
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_sync(queue, ^{
        NSLog(@"----2-----%@",[NSThread currentThread]); //线程还是1
         [self.webView stringByEvaluatingJavaScriptFromString:@"window.$sharesdk.ajsTest()"];
    });
}

-(void)analyzeURL:(NSURL*)url
{
//    初始化
    if ([url.absoluteString containsString:@"initSDK"])
    {
        NSString *appkey = nil;
        NSArray *platformArr = nil;
        NSString *wechatKey = nil;
        NSString *appSecret = nil;
        
        NSString *str1 = url.absoluteString;
//        将字符串通过指定的字符串进行分享成数组
        NSArray *arr =[str1 componentsSeparatedByString:@"&"];
        for (NSString* item in arr)
        {
            NSLog(@"%@",item);
            if ([item containsString:@"mobkey"])
            {
                appkey = [item substringFromIndex:6];
                NSLog(@"--app---%@",appkey);
            }
            if ([item containsString:@"platformArr"])
            {
                NSString *platStr = [item substringFromIndex:11];
                platformArr = [platStr componentsSeparatedByString:@","];
                NSLog(@"%@",platformArr);
            }
            if ([item containsString:@"platformConfig"])
            {
                NSString *keyStr =[item substringFromIndex:14];
                NSArray *arr =[keyStr componentsSeparatedByString:@","];
                for (NSString *key in arr)
                {
                    if ([key containsString:@"wx"])
                    {
                        wechatKey = key;
                    }else{
                        appSecret = key;
                    }
                }
            }
        }
//        获取数据完毕
        [ShareSDK registerApp:appkey
              activePlatforms:platformArr
                     onImport:^(SSDKPlatformType platformType) {
                         switch (platformType) {
                             case SSDKPlatformTypeWechat:
                                 [ShareSDKConnector connectWeChat:[WXApi class]];
                                 break;
                             default:
                                 break;
                         }
            
        } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
            switch (platformType) {
                case SSDKPlatformTypeWechat:
                    [appInfo SSDKSetupWeChatByAppId:wechatKey
                                          appSecret:appSecret];
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
}

-(void)share:(NSURL*)url
{
    NSString *text = nil;
    NSString *title = nil;
    NSString *imageUrl = nil;
    NSString *titleUrl = nil;
    NSString *type = nil;
    NSInteger typeInt = 0;
    NSString *urlStr =url.absoluteString;
    if ([urlStr containsString:@"share"])
    {
       NSArray *arr = [urlStr componentsSeparatedByString:@"&"];
        for (NSString *myitem in arr)
        {
           NSString *item = [myitem stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSLog(@"-------------%@",item);
            if ([item containsString:@"text"])
            {
                text = [item substringFromIndex:7];
               text = [text stringByRemovingPercentEncoding];   // utf-8的转码
            }
            if ([item containsString:@"title"])
            {
                title = [item substringFromIndex:8];
                title = [title stringByRemovingPercentEncoding];
            }
            if ([item containsString:@"image"])
            {
                imageUrl = [item substringFromIndex:8];
            }
            if ([item containsString:@"url"])
            {
                titleUrl = [item substringFromIndex:6];
            }
            if ([item containsString:@"type"])
            {
                type = [item substringFromIndex:7];
                if ([type isEqualToString:@"auto"])
                {
                    type = @"0";
                   typeInt = [type intValue];
                }else{
                    type = @"1";
                 typeInt= [type intValue];
                }
                
            }
        }
        //    分享
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:[NSURL URLWithString:imageUrl]
                                            url:[NSURL URLWithString:titleUrl]
                                          title:title
                                           type:typeInt];
        [ShareSDK showShareActionSheet:nil
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       NSMutableDictionary *errorDic =[NSMutableDictionary dictionary];
                       NSLog(@"oc中点击了登录");

                       switch (state)
                       {
                           case SSDKResponseStateSuccess:
                               NSLog(@"----------userData----%@",userData);
                               
                                 [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.$sharesdk.callBackData('%@')",[self jsonStringFromObject:userData]]];
                               
                               break;
                           case SSDKResponseStateFail:
                               NSLog(@"分享失败了");
                               [errorDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [NSNumber numberWithInteger:[error code]],
                                                        @"error_code",
                                                        [error userInfo],
                                                        @"error_msg",
                                                        nil]
                                                forKey:@"error"];
                               [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.$sharesdk.callBackData('%@')",[self jsonStringFromObject:errorDic]]];
                               break;
                           case SSDKResponseStateCancel:
                               NSLog(@"分享取消了");
                               [self.webView stringByEvaluatingJavaScriptFromString:@"window.$sharesdk.callBackData('分享取消了')"];
                               break;
                           default:
                               break;
                       }
        }];
    }
}

-(void)longin:(NSURL*)url
{
    if ([url.absoluteString containsString:@"login"])
    {
        [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            NSLog(@"oc中点击了登录");
            NSDictionary *userDic;
            NSMutableDictionary *errorDic = [NSMutableDictionary dictionary];
            switch (state)
            {
                case SSDKResponseStateSuccess:
                    NSLog(@"登录成功了");
                    userDic =[NSDictionary dictionaryWithObjectsAndKeys:
                              user.uid,@"uid",
                              user.nickname,@"nick",
                              nil
                              ];
                    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$sharesdk.callBackData('%@')",[self jsonStringFromObject:userDic]]];
                    break;
                case SSDKResponseStateFail:
                    NSLog(@"登录失败了");
                    [errorDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:[error code]],
                                         @"error_code",
                                         [error userInfo],
                                         @"error_msg",
                                         nil]
                                 forKey:@"error"];
                    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$sharesdk.callBackData('%@')",[self jsonStringFromObject:errorDic]]];
                    break;
                case SSDKResponseStateCancel:
                    NSLog(@"登录取消了");
                    [self.webView stringByEvaluatingJavaScriptFromString:@"$sharesdk.callBackData('登录取消了')"];
                    break;
                default:
                    break;
            }
        }];
    }

}

-(void)textLoadJson:(NSURL*)url
{
    NSLog(@"---hash------%@",url);
    if ([url.scheme isEqualToString:@"ajstest"])
    {
        NSLog(@"--  qq--%@",url.query);
        NSString *qqqq =[url.query stringByRemovingPercentEncoding];   // 对url 进行解码
        NSLog(@"----asd----%@",qqqq);
        NSDictionary *dic =[self objectFromJSONString:qqqq];
        NSLog(@"----dic---%@",dic);
   
       id wjs =[MOBFJson objectFromJSONString:qqqq];
        NSLog(@"-------%@",wjs);
        
          NSArray *arr =@[@"qq",@199];
        NSLog(@"-json--%@",[MOBFJson jsonStringFromObject:arr]);
        NSLog(@"%@",[self jsonStringFromObject:arr]);

    }
}


/**
 *  对象序列化为Json字符串
 *
 *  @param object 任意对象
 *
 *  @return Json字符串   
 */
- (NSString *)jsonStringFromObject:(id)object
{
    NSString *jsonString = [[NSString alloc]init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                      options:0
                                                        error:&error];
    if (! jsonData) {
        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    NSRange range = {0,jsonString.length};
//    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
//    NSRange range2 = {0,mutStr.length};
//    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    return mutStr;
}

/**
 *  通过JSON字符串反序列化为对象
 *
 *  @param jsonString JSON字符串
 *
 *  @return OC对象
 */
- (id)objectFromJSONString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}













@end
