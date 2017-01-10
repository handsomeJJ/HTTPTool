//
//  NetWorkManager.m
//  AF网络请求3.0最新封装
//
//  Created by none on 16/7/20.
//  Copyright © 2016年 LMJ. All rights reserved.
//

//请求超时时间

#import "NetWorkManager.h"
#import "MBProgressHUD.h"


#define TIMEOUT 10
#define KLog(...) NSLog(__VA_ARGS__)

@interface LZUploadParam : NSObject
@property (nonatomic, strong) NSData *data;//二进制数据
@property (nonatomic, copy) NSString *name;//名称
@property (nonatomic, copy) NSString *fileName;//文件名称
@property (nonatomic, copy) NSString *mimeType;//文件类型(e.g image/jpeg video/mp4)
@property (nonatomic, copy) NSString *filePath;//文件地址
@end
@implementation LZUploadParam
@end

static NetWorkManager *sharedNetworkSingleton = nil;

@implementation NetWorkManager

+(NetWorkManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedNetworkSingleton = [[self alloc] init];
    });
    return sharedNetworkSingleton;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedNetworkSingleton == nil) {
            
            sharedNetworkSingleton = [super allocWithZone:zone];
        }
    });
    return sharedNetworkSingleton;
}

-(AFHTTPSessionManager *)baseHtppRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //header 设置
//    [manager.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appversion"];
    /*
     *  项目请求头
     */
    NSString *key = @"uT2NYRFhMEyFQxxm";
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    
    NSString *a  = [NSString stringWithFormat:@"%llu",recordTime];
    NSString *time = [a substringFromIndex:3];
    
    NSString *m =[NSString stringWithFormat:@"%@%@1",key,time];
    
    NSString *API_AuthKey =[m md5HexDigest];
    manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer setValue:API_AuthKey forHTTPHeaderField:@"API-AuthKey"];
    [manager.requestSerializer setValue:time forHTTPHeaderField:@"API-AuthTime"];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"API-SourceID"];
    
    //设置返回格式
    AFJSONResponseSerializer *jsonRes = [AFJSONResponseSerializer serializer];
    jsonRes.removesKeysWithNullValues=YES;
    manager.responseSerializer = jsonRes;
    //超时时间
    [manager.requestSerializer setTimeoutInterval:TIMEOUT];
    
    return manager;
}
#pragma mark - GET
+(void)get:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    
    [[[self class] sharedManager] get:url params:parameter progress:nil success:successBlock failure:failureBlock];
}

-(void)get:(NSString *)url params:(NSDictionary *)parameter progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
     KLog(@"请求地址:\n%@\n参数:%@",url,parameter);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager  =[self baseHtppRequest];
    [manager GET:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

//        KLog(@"返回结果:\n%@",[[self class] logDic:responseObject]);
        if (successBlock) {
            successBlock(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
//        KLog(@"%@\n返回结果:%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
        if (failureBlock) {
            failureBlock(task,error);
        }
    }];
}


#pragma mark - POST
+(void)post:(NSString *)url params:(NSDictionary *)parameter success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    
    [[[self class] sharedManager] post:url params:parameter progress:nil success:successBlock failure:failureBlock];
}

-(void)post:(NSString *)url params:(NSDictionary *)parameter progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    KLog(@"请求地址:\n%@\n参数:%@",url,parameter);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager  =[self baseHtppRequest];
    [manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//         KLog(@"返回结果:\n%@", [[self class] logDic:responseObject]);
        if (successBlock) {
            successBlock(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//          KLog(@"%@\n返回结果:%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
  
        if (failureBlock) {
            failureBlock(task,error);
        }
    }];
}
#pragma mark upLoad上传
-(void)upLoadFileWithModel:(LZUploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
   successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
   AFHTTPSessionManager *manager = [self baseHtppRequest];
    [manager POST:urlStr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:uploadModel.filePath] name:uploadModel.name fileName:uploadModel.fileName mimeType:uploadModel.mimeType error:nil];
        //e.g: image/jpeg video/mp4 application/octet-stream
    } progress:progressBlock success:successBlock failure:failureBlock];

}
#pragma mark downLoad下载
-(void)downLoadFileWithUrl:(NSString *)urlStr progress:(ProgressBlock)progressBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *  error))block{
    
    AFHTTPSessionManager *manager = [self baseHtppRequest];
  
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL URLWithString:filePath];

    } completionHandler:block];
    
    //开始启动任务
    [task resume];
}
#pragma makr - 开始监听网络
+ (void)startMonitoring
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 使用MBProgressHUD三方库创建弹框，给出相应的提示
        UIWindow *wind = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:wind animated:YES];
        hud.mode = MBProgressHUDModeText;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                // 弹框提示的内容
                hud.label.text = @"当前网络开小差";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CONNECTED" object:nil];
                hud.label.text = @"当前使用2G/3G/4G";
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CONNECTED" object:nil];
                hud.label.text = @"当前使用WiFi";
            }
                
            default:
                break;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 显示时间2s
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 让弹框消失
                [MBProgressHUD hideHUDForView:wind animated:YES];
            });
        });
    }];
    [manager startMonitoring];
    
}
+ (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL  error:NULL];
    return str;
}



@end
