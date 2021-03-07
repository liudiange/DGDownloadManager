//
//  DGBackgroudDownloadManager.h
//  DGDownloadManager
//
//  Created by Brown on 2/24/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGBackgroudDownloadModel.h"
#import "DGBackgroudDownloadSaveModel.h"


@interface DGBackgroudDownloadManager : NSObject

+ (instancetype)shareManager;

#pragma mark -- 外界提供的属性和方法

/** 最大任务数量*/
@property (nonatomic, assign) int DG_MaxTaskCount;

/** 是否在网络恢复的情况下，自动恢复下载功能,默认为false*/
@property (nonatomic, assign) BOOL DG_AutoDownload;

/** 存放数据源数组*/
@property (nonatomic, strong, readonly) NSMutableArray *DG_BackgroudDownloadArray;

#pragma mark--下载的方法
/* 处理后台通知的相关事件需要在这个方法中写入
 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
 @param completionHandler completionHandler
 @param identifier identifier
 */
- (void)handleBackgroudcompletionHandler:(void(^)(void))completionHandler
                              identifier:(NSString *)identifier;


/**
 开始下载
 
 @param downloadUrl 下载的路径
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
#pragma mark--获取数据相关
/**
 获取所有下载完成的数据model的数据源
 */
- (NSMutableArray<DGBackgroudDownloadSaveModel *> *)DG_GetAllDownloadModels;


@end

