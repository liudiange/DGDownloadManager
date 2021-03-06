//
//  DGBackgroudDownloadModel.h
//  DGDownloadManager
//
//  Created by Brown on 2/24/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DGBackgroudDownloadDelegate.h"

// 是否下载 1.等待中 2.正在下载  3.暂停  4.下载完成 5.下载失败
typedef NS_ENUM(NSUInteger,DGBackgroudDownloadStatus) {
    
    DGBackgroudDownloadStatusUnKnown            = 0,
    DGBackgroudDownloadStatusWaiting            = 1,
    DGBackgroudDownloadStatusDownloading        = 2,
    DGBackgroudDownloadStatusDownloadSuspend    = 3,
    DGBackgroudDownloadStatusDownloadFinish     = 4,
    DGBackgroudDownloadStatusError              = 5
};

@interface DGBackgroudDownloadModel : NSObject

/** 下载的自定义的缓存文件名*/
@property (nonatomic, copy) NSString *customCacheName;

/** 下载的任务 */
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/** 下载的session */
@property (nonatomic, strong) NSURLSession *session;

/** 请求的url */
@property (nonatomic, copy) NSString *requestUrl;

/** 下载的状态 */
@property (nonatomic, assign) DGBackgroudDownloadStatus downloadStatus;

/** 下载的进度 */
@property (nonatomic, assign, readonly) CGFloat progress;

/** 缓存的文件的路径 */
@property (nonatomic, copy) NSString *cachePath;

/** DGBackgroudDownloadDelegate 用作代理 */
@property (nonatomic, strong) DGBackgroudDownloadDelegate *downloaDelegate;

/** 下载进度的block */
@property (nonatomic, strong) DownloadProgressBlock downloadProgressBlock;

/** 下载信息反馈 */
@property (nonatomic, strong) DownloadErrorBlock downloadErrorBlock;

/** 下载完成反馈 */
@property (nonatomic, strong) DownloadFinishBlock downloadFinishBlcok;


@end

