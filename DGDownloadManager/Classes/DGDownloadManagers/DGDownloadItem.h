//
//  DGDownloadItem.h
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGDownloadItem.h"
#import "DGHttpConfig.h"
#import <AFNetworking/AFNetworking.h>

// 是否下载 1.等待中 2.正在下载  3.暂停  4.下载完成 5.下载失败
typedef NS_ENUM(NSUInteger,DGDownloadStatus) {
    
    DGDownloadStatusUnKnown            = 0,
    DGDownloadStatusWaiting            = 1,
    DGDownloadStatusDownloading        = 2,
    DGDownloadStatusDownloadSuspend    = 3,
    DGDownloadStatusDownloadFinish     = 4,
    DGDownloadStatusError              = 5
};

@interface DGDownloadItem : NSObject

/** 下载的自定义的缓存文件名*/
@property (nonatomic, copy) NSString *customCacheName;

/** 请求的url */
@property (nonatomic, copy) NSString *requestUrl;

/** 下载的任务 */
@property (nonatomic, strong) NSURLSessionTask *task;

/** 管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;

/** 下载的状态 */
@property (nonatomic, assign) DGDownloadStatus downloadStatus;

/** 返回的response */
@property (nonatomic, strong) NSURLResponse *response;

/** 错误的信息 */
@property (nonatomic, strong) NSError *error;

/** 下载的进度 */
@property (nonatomic, assign) CGFloat progress;

/** 临时存储的文件路径 */
@property (nonatomic, copy) NSString *temPath;

/** 缓存的文件的路径 */
@property (nonatomic, copy) NSString *cachePath;

/** 请求的方法 */
@property (nonatomic, copy) NSString *requestMethod;

/** 参数 */
@property (nonatomic, strong) NSDictionary *paramDic;

/** NSFileHandle */
@property (nonatomic, strong) NSFileHandle *itemFileHandle;

//  下载进度的block
@property (nonatomic, strong) void (^DGDownloadProgressBlock)(CGFloat progress);

//  下载信息反馈
@property (nonatomic, strong) void (^DGDownloadCompletionHandler)(NSError *error);


@end


