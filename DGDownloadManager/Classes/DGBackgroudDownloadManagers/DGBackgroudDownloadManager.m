//
//  DGBackgroudDownloadManager.m
//  DGDownloadManager
//
//  Created by Brown on 2/24/21.
//  Copyright © 2021 apple. All rights reserved.
//
#import "DGBackgroudDownloadManager.h"
#import "DGBackgroudDownloadCacheManager.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "NSData+Category.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>


#define  MAXTASK_COUNT  3
typedef void(^CompletionHandlerType)(void);

@interface DGBackgroudDownloadManager ()

/** 锁*/
@property (nonatomic, strong) NSLock *lock;

/** 存放identifier的字典*/
@property (nonatomic, strong) NSMutableDictionary *cacheDic;

/** 存放下载model的数据*/
@property (nonatomic, strong) NSMutableArray *DG_DownloadArray;


@end

@implementation DGBackgroudDownloadManager

+ (instancetype)shareManager{
    
    static DGBackgroudDownloadManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
    
}
- (instancetype)init {
    if (self == [super init]) {
        self.lock = [[NSLock alloc] init];
        [self listenNetwork];
    }
    return self;
}

#pragma mark - 懒加载
- (NSMutableArray <DGBackgroudDownloadModel *>*)DG_DownloadArray {
    if (!_DG_DownloadArray) {
        _DG_DownloadArray = [NSMutableArray array];
    }
    return _DG_DownloadArray;
}

- (NSMutableDictionary *)cacheDic {
    if (!_cacheDic) {
        _cacheDic = [NSMutableDictionary dictionary];
    }
    return _cacheDic;
}
-(NSMutableArray *)DG_BackgroudDownloadArray{
    return self.DG_DownloadArray;
}

#pragma mark -- 其他事件的相应

/* 处理后台通知的相关事件需要在这个方法中写入
 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
 @param completionHandler completionHandler
 @param identifier identifier
 */
- (void)handleBackgroudcompletionHandler:(void(^)(void))completionHandler
                              identifier:(NSString *)identifier{
    if (identifier.length > 0) {
        self.cacheDic[identifier] = completionHandler;
    }
}

/**
 开始下载
 
 @param downloadUrl 下载的路径
 @param customCacheName 自定义的缓存的名字
 */
- (void)DG_DownloadWithUrl:(NSString *)downloadUrl
       withCustomCacheName:(NSString *)customCacheName{
    
    // 为空不处理
    if (downloadUrl.length == 0) {
        return;
    }
    // 判断缓存中是否存在,说明已经下载过了
    NSString *cachePath = [self getCache:downloadUrl customCahceName:customCacheName];
    if ([[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:nil].fileSize > 0) {
        return;
    }
    
    [self.lock lock];
    DGBackgroudDownloadModel *model = [self getItemFromArray:_DG_DownloadArray withUrl:downloadUrl];
    if (!model) {
        model = [[DGBackgroudDownloadModel alloc] init];
        model.requestUrl = downloadUrl;
        model.downloadStatus = DGBackgroudDownloadStatusWaiting;
        model.customCacheName = customCacheName;
        model.cachePath = [self getCache:downloadUrl customCahceName:customCacheName];
        [self.DG_DownloadArray addObject:model];
    }else{
        model.downloadStatus = DGBackgroudDownloadStatusWaiting;
    }
    
    [self DG_CheckDownload];
    [_lock unlock];
}

/**
 暂停某一个下载
 
 @param url 暂停的全下载路径
 */
- (void)DG_SuspendWithUrl:(NSString *)url{
    
    if (url.length == 0) {
        return;
    }
    DGBackgroudDownloadModel *model = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    if (!model) {
        return;
    }
    model.downloadStatus = DGBackgroudDownloadStatusDownloadSuspend;
    __weak typeof(DGBackgroudDownloadModel *)weakModel = model;
    [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakModel.downloaDelegate.resumeData = resumeData;
    }];
}

/**
 暂停所有的下载
 */
- (void)DG_SuspendAllRequest{
    
    [_lock lock];
    for (DGBackgroudDownloadModel *model in _DG_DownloadArray) {
        if (model.downloadStatus == DGBackgroudDownloadStatusDownloading || model.downloadStatus == DGBackgroudDownloadStatusWaiting || model.downloadStatus == DGBackgroudDownloadStatusError) {
            model.downloadStatus = DGBackgroudDownloadStatusDownloadSuspend;
            __weak typeof(DGBackgroudDownloadModel *)weakModel = model;
            [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                weakModel.downloaDelegate.resumeData = resumeData;
            }];
        }
    }
    [_lock unlock];
}
/**
 恢复某一个下载
 
 @param url 下载的全链接
 */
- (void)DG_ResumeWithUrl:(NSString *)url {
    
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    DGBackgroudDownloadModel *model = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    if (!model) {
        model = [[DGBackgroudDownloadModel alloc] init];
        model.requestUrl = url;
        model.downloadStatus = DGBackgroudDownloadStatusWaiting;
        [_DG_DownloadArray addObject:model];
    }else{
        model.downloadStatus = DGBackgroudDownloadStatusWaiting;
    }
    [_lock unlock];
    [self DG_CheckDownload];
    
}
/**
 恢复所有暂停的下载
 */
- (void)DG_ResumeAllRequest{
    
    [_lock lock];
    for (DGBackgroudDownloadModel *model in _DG_DownloadArray) {
        if (model.downloadStatus != DGBackgroudDownloadStatusError || model.downloadStatus != DGBackgroudDownloadStatusDownloadFinish) {
            model.downloadStatus = DGBackgroudDownloadStatusWaiting;
        }
    }
    [self DG_CheckDownload];
    [_lock unlock];
}
/**
 取消一个下载
 
 @param url 下载的全链接
 */
- (void)DG_CancelWithUrl:(NSString *)url {
    
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    DGBackgroudDownloadModel *model = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    if (model.downloadStatus == DGBackgroudDownloadStatusDownloadFinish) {
        return;
    }else {
        [model.task cancel];
        model.task = nil;
    }
    if (model) {
        [_DG_DownloadArray removeObject:model];
    }
    [_lock unlock];
    
}
/**
 取消所有的下载的任务
 */
- (void)DG_CancelAllRequest{
    
    if (_DG_DownloadArray.count == 0) {
        return;
    }
    
    [_lock lock];
    for (DGBackgroudDownloadModel *model in _DG_DownloadArray) {
        [model.session invalidateAndCancel];
        model.downloaDelegate.resumeData = nil;
        [model.task cancel];
        model.task = nil;
    }
    [_DG_DownloadArray removeAllObjects];
    _DG_DownloadArray = nil;
    [_lock unlock];
}
#pragma mark - 自身需要实现的方法
/**
 便利数组获取item
 
 @param itemArray 传递的数组
 @param url url
 @return 单个下载的对象
 */
- (DGBackgroudDownloadModel *)getItemFromArray:(NSArray <DGBackgroudDownloadModel *>*)itemArray
                                       withUrl:(NSString *)url {
    DGBackgroudDownloadModel *itemModel = nil;
    for (DGBackgroudDownloadModel *model in itemArray) {
        if ([model.requestUrl isEqualToString:url]) {
            itemModel = model;
            break;
        }
    }
    return itemModel;
}
/// 获取缓存的文件夹的路径
/// @param downloadUrl downloadUrl
/// @param customCacheName 自定义图片的名字
- (NSString *)getCache:(NSString *)downloadUrl
       customCahceName:(NSString *)customCacheName{
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DGBackgroudDownload"];
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 方案二 自己用md5 或者其他的方式加密命名
    if (customCacheName.length > 0) {
        cachePath = [cachePath stringByAppendingPathComponent:customCacheName];
    }else {
        NSString *lastComponent = downloadUrl.lastPathComponent;
        if (lastComponent.length == 0) {
            lastComponent = [[[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString] stringByAppendingString:@".download"];
        }
        cachePath = [cachePath stringByAppendingPathComponent: lastComponent];
    }
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createFileAtPath:cachePath contents:nil attributes:nil];
    }
    return cachePath;
}

/**
 检查下载相关的
 */
- (void)DG_CheckDownload {
    
    NSInteger downloadingCount = 0;
    BOOL flag = YES;
    for (DGBackgroudDownloadModel *model in _DG_DownloadArray) {
        if (model.downloadStatus == DGBackgroudDownloadStatusDownloading) {
            downloadingCount ++;
        }
        if (self.DG_MaxTaskCount == 0) {
            self.DG_MaxTaskCount = MAXTASK_COUNT;
        }
        if (downloadingCount >= self.DG_MaxTaskCount) {
            flag = NO;
            break;
        }
    }
    if (flag) {
        for (DGBackgroudDownloadModel *model in _DG_DownloadArray) {
            if (model.downloadStatus == DGBackgroudDownloadStatusWaiting) {
                if (self.DG_MaxTaskCount == 0) {
                    self.DG_MaxTaskCount = MAXTASK_COUNT;
                }
                if (self.DG_MaxTaskCount - downloadingCount > 0) {
                    [self DG_BeginDownloadWithModel: model];
                    downloadingCount ++;
                }else {
                    break;
                }
            }
        }
    }
}
/**
 开始单个下载的任务

 @param model model
 */
- (void)DG_BeginDownloadWithModel:(DGBackgroudDownloadModel *)model {
    
    if (model.requestUrl.length == 0 || model.downloadStatus == DGBackgroudDownloadStatusDownloading) {
        return;
    }
    
    __weak typeof(DGBackgroudDownloadModel *)weakModel = model;
    
    model.downloadStatus = DGBackgroudDownloadStatusDownloading;
    if (model.task) {
        [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            weakModel.downloaDelegate.resumeData = resumeData;
        }];
    }else{
        // 回掉错误代理可以拿到resumedata
        [model.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            
        }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (model.downloaDelegate.resumeData.length == 0) {
            model.downloaDelegate.resumeData = [DGBackgroudDownloadCacheManager getResumeData:model.requestUrl];
        }
        [self handleModel:model];
    });
    
}

/// model 的相关的监听
/// @param model model
- (void)handleModel:(DGBackgroudDownloadModel *)model {
    
    __weak typeof(DGBackgroudDownloadModel *)weakModel = model;
    __weak typeof(self)weakSelf = self;
    
    if (model.downloaDelegate.resumeData.length > 0) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.2) {
            model.task = [model.session downloadTaskWithResumeData: model.downloaDelegate.resumeData];
        }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10){
            model.task = [model.session downloadTaskWithCorrectResumeData: model.downloaDelegate.resumeData];
        }else{
            model.task = [model.session downloadTaskWithResumeData:model.downloaDelegate.resumeData];
        }
        [model.task resume];
        
    }else{
        NSURL *downloadUrl = [NSURL URLWithString:model.requestUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
        model.task = [model.session downloadTaskWithRequest:request];
        [model.task resume];
    }
    // 移除老的resumeData
    [DGBackgroudDownloadCacheManager deleteResumeDataWithUrl:model.requestUrl];
    
    // 监听过了不在监听
    if (model.downloaDelegate.downloadFinishBlock) {
        return;
    }
    
    // 各种监听
    model.downloaDelegate.downloadFinishBlock = ^(NSURLSessionDownloadTask *downloadTask, NSURL *location) {

        weakModel.downloadStatus = DGBackgroudDownloadStatusDownloadFinish;
        // 删除文件，防止出现错误
        [[NSFileManager defaultManager] removeItemAtPath:weakModel.cachePath error:nil];
        
        NSError *transError = nil;
        NSString *locationString = [location path];
        [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:weakModel.cachePath error:&transError];
        [[NSFileManager defaultManager] removeItemAtPath:locationString error:nil];
        
        // 删除resumedata
        [DGBackgroudDownloadCacheManager deleteResumeDataWithUrl:weakModel.requestUrl];

        [weakModel.session invalidateAndCancel];
        [weakModel.task cancel];
        weakModel.task = nil;
        
        // 存储model
        [DGBackgroudDownloadCacheManager saveDownloadModel:weakModel];

        [weakSelf.lock lock];
        [weakSelf.DG_DownloadArray removeObject:weakModel];
        [weakSelf DG_CheckDownload];
        [weakSelf.lock unlock];

        if (weakModel.downloadFinishBlcok) {
            weakModel.downloadFinishBlcok(downloadTask, location);
        }
    };

    model.downloaDelegate.downloadProgressBlock = ^(CGFloat progress,CGFloat speed) {
        if (weakModel.downloadProgressBlock) {
            weakModel.downloadProgressBlock(progress,speed);
        }
    };

    model.downloaDelegate.downloadErrorBlock = ^(NSError *error) {
        weakModel.downloadStatus = DGBackgroudDownloadStatusError;
        if (weakModel.cachePath.length > 0 &&
            [[NSFileManager defaultManager] attributesOfItemAtPath:weakModel.cachePath error:nil].fileSize > 0) {
            return;
        }
        if (weakModel.downloadErrorBlock && !error) {
            weakModel.downloadErrorBlock(error);
        }
    };

    model.downloaDelegate.downloadFinishEventBlock = ^(NSString *identifier) {
        weakModel.downloadStatus = DGBackgroudDownloadStatusDownloadFinish;
        if ([weakSelf.cacheDic.allKeys containsObject:identifier]) {
            CompletionHandlerType completionHandler = weakSelf.cacheDic[identifier];
            if (completionHandler) {
                completionHandler();
            }
            [weakSelf.cacheDic removeObjectForKey:identifier];
        }
    };
}
#pragma mark--获取数据相关
/**
 获取所有下载完成的数据model的数据源
 */
- (NSMutableArray<DGBackgroudDownloadSaveModel *> *)DG_GetAllDownloadModels{
    
    return [DGBackgroudDownloadCacheManager getAllDownloadModels];
}

#pragma mark -- 内部监听方法调用

/// 监听网络变化自动恢复下载
- (void)listenNetwork{
    
    __weak typeof(DGBackgroudDownloadManager *)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                if (weakSelf.DG_AutoDownload) {
                    [weakSelf DG_ResumeAllRequest];
                }
            }
             break;
            default:
                break;
        }
    }];
}

@end
