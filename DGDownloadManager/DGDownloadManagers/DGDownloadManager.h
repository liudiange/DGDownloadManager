//
//  DGDownloadManager.h
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGDownloadItem.h"

#define  MAXTASK_COUNT  3
@interface DGDownloadManager : NSObject

+ (instancetype)shareManager;

#pragma mark - 外部可以拿到的相关的属性

/** 最大任务数量*/
@property (nonatomic, assign) int DG_MaxTaskCount;
// 存放需要下载的数组
@property (nonatomic, strong) NSMutableArray *DG_DownloadArray;

#pragma mark - 外部调用的方法
/**
 开始下载
 
 @param downloadUrl 下载的路径
 @param requestMethod 请求的方法
 @param customCacheName 自定义的缓存的名字
 */
- (void)DG_DownloadWithUrl:(NSString *)downloadUrl
                withMethod:(NSString *)requestMethod
       withCustomCacheName:(NSString *)customCacheName;
/**
  开始下载

 @param downloadUrl 下载的路径 (请求的方式是get)
 @param customCacheName 自定义的缓存的名字
 */
- (void)DG_DownloadWithUrl:(NSString *)downloadUrl
       withCustomCacheName:(NSString *)customCacheName;

/**
 暂停某一个下载
 
 @param url 暂停的全下载路径
 */
- (void)DG_SuspendWithUrl:(NSString *)url;

/**
 暂停所有的下载
 */
- (void)DG_SuspendAllRequest;

/**
 恢复某一个下载
 
 @param url 下载的全链接
 */
- (void)DG_ResumeWithUrl:(NSString *)url;
/**
 恢复所有暂停的下载
 */
- (void)DG_ResumeAllRequest;

/**
 取消一个下载
 
 @param url 下载的全链接
 */
- (void)DG_CancelWithUrl:(NSString *)url;


/**
 取消所有的下载的任务
 */
- (void)DG_CancelAllRequest;

@end


