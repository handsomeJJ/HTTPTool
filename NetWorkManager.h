//
//  NetWorkManager.h
//  AF网络请求3.0最新封装
//
//  Created by none on 16/7/20.
//  Copyright © 2016年 LMJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class LZUploadParam;
typedef void(^SuccessBlock)(NSURLSessionDataTask * task , id  responseObject);
typedef void(^FailureBlock)(NSURLSessionDataTask * task , NSError * error);
typedef void(^ProgressBlock)(NSProgress * downloadProgress);


typedef void(^BlockAction)();
typedef void(^GroupResponseFailure)(NSArray * errorArray);
static char groupErrorKey;
static char queueGroupKey;

@interface NetWorkManager : AFHTTPSessionManager
+(NetWorkManager *)sharedManager;



#pragma mark - GET
/*
 * 简单get请求，不带下载进度条
 */
+(void)get:(NSString *)url params:(NSDictionary *)parameter success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
/*
 * get请求，带下载进度条
 */
-(void)get:(NSString *)url params:(NSDictionary *)parameter progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;



#pragma mark - POST
/*
 * 简单post请求，不带下载进度条
 */
+(void)post:(NSString *)url params:(NSDictionary *)parameter success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
/*
 * post请求，带下载进度条
 */
-(void)post:(NSString *)url params:(NSDictionary *)parameter progress:(ProgressBlock)progressBlock success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;


#pragma mark upLoad上传
-(void)upLoadFileWithModel:(LZUploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
              successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;



#pragma mark downLoad下载
-(void)downLoadFileWithUrl:(NSString *)urlStr progress:(ProgressBlock)progressBlock completionBlock:(void (^)(NSURLResponse * response, NSURL *  filePath, NSError *  error))block;



#pragma mark - 开始监听网络
+ (void)startMonitoring;
+ (NSString *)logDic:(NSDictionary *)dic;

@end
