//
//  DGBackgroudDownloadDelegate.h
//  DGDownloadManager
//
//  Created by Brown on 2/25/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadFinishBlock)(NSURLSessionDownloadTask *downloadTask,NSURL *location);

// speed 是kb/s
typedef void(^DownloadProgressBlock)(CGFloat progress,CGFloat speed);

typedef void(^DownloadErrorBlock)(NSError *error);

typedef void(^DownloadFinishEventBlock)(NSString *identifier);

@interface DGBackgroudDownloadDelegate :NSObject <NSURLSessionDownloadDelegate,NSURLSessionDelegate>

/** resumeData使用 */
@property (nonatomic, strong) NSData *resumeData;

/** 下载完成回调 */
@property (nonatomic, strong) DownloadFinishBlock downloadFinishBlock;

/** 下载进度条回调 */
@property (nonatomic, strong) DownloadProgressBlock downloadProgressBlock;

/** 下载出错回调 */
@property (nonatomic, strong) DownloadErrorBlock downloadErrorBlock;

/** 下载完成后台session回调 */
@property (nonatomic, strong) DownloadFinishEventBlock downloadFinishEventBlock;

/// 获取下载的进度
- (CGFloat)getDownloadProgress;

@end

