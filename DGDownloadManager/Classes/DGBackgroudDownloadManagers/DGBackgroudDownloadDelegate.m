//
//  DGBackgroudDownloadDelegate.m
//  DGDownloadManager
//
//  Created by Brown on 2/25/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DGBackgroudDownloadDelegate.h"
#import "NSData+Category.h"
#import "DGBackgroudDownloadCacheManager.h"

@interface DGBackgroudDownloadDelegate ()

/** 当前的进度*/
@property (nonatomic, assign) CGFloat progress;

/** 当前的时间毫秒级*/
@property (nonatomic, assign) long long int lastTime;

/** 上一次的写入多少*/
@property (nonatomic, assign) int64_t lastBytesWritten;


@end

@implementation DGBackgroudDownloadDelegate

#pragma mark - 公共方法

/// 获取下载的进度
- (CGFloat )getDownloadProgress{
    return  self.progress;
}

#pragma mark - 代理

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    if (self.downloadFinishBlock) {
        self.downloadFinishBlock(downloadTask,location);
    }

}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    long long int currentTime = [[[NSDate alloc] init] timeIntervalSince1970] *1000;
    long long int subtractTime = 0;
    if (self.lastTime > 0) {
        subtractTime = currentTime - self.lastTime;
    }else{
        subtractTime = 1000;
    }
    // 多少 k/s  totalBytesWritten是字节
    CGFloat speed = (CGFloat)(totalBytesWritten - self.lastBytesWritten) / subtractTime;
    
    self.progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(self.progress,speed);
    }
    
    self.lastTime = currentTime;
    self.lastBytesWritten = totalBytesWritten;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    if (session.configuration.identifier && self.downloadFinishEventBlock) {
        if (self.downloadFinishEventBlock) {
            self.downloadFinishEventBlock(session.configuration.identifier);
        }
    }
}
/*
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的，
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    if (error) {
        if ([error.userInfo.allKeys containsObject:NSURLSessionDownloadTaskResumeData]) {
            
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if (resumeData.length) {
                self.resumeData = resumeData;
                [DGBackgroudDownloadCacheManager saveResumeDataWithUrl:task.currentRequest.URL.absoluteString resumeData:resumeData];
            }
        }
        if (self.downloadErrorBlock) {
            self.downloadErrorBlock(error);
        }
    }
}


@end
