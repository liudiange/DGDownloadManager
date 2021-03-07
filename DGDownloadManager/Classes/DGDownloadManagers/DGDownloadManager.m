//
//  DGDownloadManager.m
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "DGDownloadManager.h"
#import "NSDataAdditions.h"
#import "DGFileManager.h"
#import <AFNetworking/AFNetworking.h>

@interface DGDownloadManager ()
// 锁
@property(nonatomic, strong)NSLock *lock;

@end

@implementation DGDownloadManager
+ (instancetype)shareManager {
    static DGDownloadManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
-(instancetype)init {
    if (self == [super init]) {
        _lock = [[NSLock alloc] init];
        // 增加网络变化
        [self listenNetwork];
        
    }
    return self;
}
#pragma mark - 懒加载
-(NSMutableArray *)DG_DownloadArray {
    if (!_DG_DownloadArray) {
        _DG_DownloadArray = [NSMutableArray array];
    }
    return _DG_DownloadArray;
}
#pragma mark - 外部调用的方法
/**
 开始下载
 
 @param downloadUrl 下载的路径
 @param requestMethod 请求的方法
 @param customCacheName 自定义的缓存的名字
 */
- (void)DG_DownloadWithUrl:(NSString *)downloadUrl
                withMethod:(NSString *)requestMethod
       withCustomCacheName:(NSString *)customCacheName{
    
    if (downloadUrl.length == 0) { return;}
    [_lock lock];
    // 取消下载相关的东西
    DGDownloadItem *item = [self getItemFromArray:_DG_DownloadArray withUrl:downloadUrl];
    if (!item) {
        item = [[DGDownloadItem alloc] init];
        item.requestUrl = downloadUrl;
        item.downloadStatus = DGDownloadStatusWaiting;
        item.progress = 0.0;
        item.customCacheName = customCacheName;
        item.temPath = [self getTemPath:downloadUrl];
        // 方案二需要这样写
        item.cachePath = [self getCache:downloadUrl withResponse:nil customCahceName:customCacheName];
        item.requestMethod = requestMethod;
        item.paramDic = nil;
        // 已经下载的就不用下载了
        if ([[NSFileManager defaultManager] attributesOfItemAtPath:item.cachePath error:nil].fileSize <= 0) {
            [self.DG_DownloadArray addObject:item];
        }
    }
    // 设置最大线程来进行下载任务
    [self DG_CheckDownload];
    [_lock unlock];
}
/**
 开始下载
 
 @param downloadUrl 下载的路径 (请求的方式是get)
 @param customCacheName 自定义的缓存的名字
 */
- (void)DG_DownloadWithUrl:(NSString *)downloadUrl
       withCustomCacheName:(NSString *)customCacheName{
    
    if (downloadUrl.length == 0) { return;}
    [_lock lock];
    // 取消下载相关的东西
    DGDownloadItem *item = [self getItemFromArray:_DG_DownloadArray withUrl:downloadUrl];
    if (!item) {
        item = [[DGDownloadItem alloc] init];
        item.requestUrl = downloadUrl;
        item.downloadStatus = DGDownloadStatusWaiting;
        item.progress = 0.0;
        item.customCacheName = customCacheName;
        item.temPath = [self getTemPath:downloadUrl];
        // 方案二需要这样写
        item.cachePath = [self getCache:downloadUrl withResponse:nil customCahceName:customCacheName];
        item.requestMethod = @"GET";
        item.paramDic = nil;
        // 已经下载的就不用下载了
        if ([[NSFileManager defaultManager] attributesOfItemAtPath:item.cachePath error:nil].fileSize <= 0) {
            [self.DG_DownloadArray addObject:item];
        }
    }
    // 设置最大线程来进行下载任务
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
    [_lock lock];
    DGDownloadItem *item = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    [item.task suspend];
    item.downloadStatus = DGDownloadStatusDownloadSuspend;
    // 暂停某一首歌曲
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSuspendOneSong object:nil];
    [_lock unlock];
    
}

/**
 暂停所有的下载
 */
- (void)DG_SuspendAllRequest{
    [_lock lock];
    for (DGDownloadItem *item in _DG_DownloadArray) {
        if (item.downloadStatus == DGDownloadStatusDownloading || item.downloadStatus == DGDownloadStatusWaiting || item.downloadStatus == DGDownloadStatusError) {
            [item.task suspend];
            item.downloadStatus = DGDownloadStatusDownloadSuspend;
        }
    }
    [_lock unlock];
    // 暂停所有的歌曲（通知）
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSuspendAllSong object:nil];
}
/**
 恢复某一个下载
 
 @param url 下载的全链接
 */
- (void)DG_ResumeWithUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    DGDownloadItem *item = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    if (!item) {
        item = [[DGDownloadItem alloc] init];
        item.requestUrl = url;
        item.downloadStatus = DGDownloadStatusWaiting;
        item.progress = 0.0;
        item.temPath = [self getTemPath:url];
        item.paramDic = nil;
        [_DG_DownloadArray addObject:item];
    }else {
        item.downloadStatus = DGDownloadStatusWaiting;
    }
    [self DG_CheckDownload];
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGResumeOneSong object:nil];
}
/**
 恢复所有暂停的下载
 */
- (void)DG_ResumeAllRequest{
    [_lock lock];
    for (DGDownloadItem *item in _DG_DownloadArray) {
        if (item.downloadStatus != DGDownloadStatusError || item.downloadStatus != DGDownloadStatusDownloadFinish) {
            item.downloadStatus = DGDownloadStatusWaiting;
        }
    }
    [self DG_CheckDownload];
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGResumeAllSong object:nil];
}
/**
 取消一个下载
 
 @param url 下载的全链接
 */
- (void)DG_CancelWithUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    [_lock lock];
    DGDownloadItem *item = [self getItemFromArray:_DG_DownloadArray withUrl:url];
    if (item.downloadStatus == DGDownloadStatusDownloadFinish) {
        return;
    }else {
        [item.task cancel];
        item.task = nil;
        // 删除临时文件夹的缓存东西
        [[NSFileManager defaultManager] removeItemAtPath:item.temPath error:nil];
    }
    if (item) {
        [_DG_DownloadArray removeObject:item];
    }
    [_lock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGCancelOneSong object:nil];
}
/**
 取消所有的下载的任务
 */
- (void)DG_CancelAllRequest{
    [_lock lock];
    for (DGDownloadItem *item in _DG_DownloadArray) {
        [item.task cancel];
        item.task = nil;
        // 删除临时文件夹的缓存东西
        [[NSFileManager defaultManager] removeItemAtPath:item.temPath error:nil];
    }
    [_DG_DownloadArray removeAllObjects];
    _DG_DownloadArray = nil;
    [_lock unlock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DGCancelAllSong object:nil];
}
#pragma mark--获取数据相关
/**
 获取所有下载完成的数据model的数据源
 */
- (NSMutableArray<DGDownloadSaveItem *> *)DG_GetAllDownloadItems{
    return [DGFileManager getAllDownloadItems];
}
#pragma mark - 自身需要实现的方法
/**
 便利数组获取item
 
 @param itemArray 传递的数组
 @param url url
 @return 单个下载的对象
 */
- (DGDownloadItem *)getItemFromArray:(NSArray <DGDownloadItem *>*)itemArray withUrl:(NSString *)url {
    DGDownloadItem *getItem = nil;
    for (DGDownloadItem *item in itemArray) {
        if ([item.requestUrl isEqualToString:url]) {
            getItem = item;
            break;
        }
    }
    return getItem;
}
/**
 获取临时文件夹 (全路径）
 
 @param downloadUrl 下载的全路径
 @return 临时文件的路径
 */
-  (NSString *)getTemPath:(NSString *)downloadUrl {
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *temPath = NSTemporaryDirectory();
    NSString *nameStr =[[[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString] stringByAppendingString:@".download"];
    temPath = [temPath stringByAppendingPathComponent:nameStr];
    if (![fileManager fileExistsAtPath:temPath]) {
        [fileManager createFileAtPath:temPath contents:nil attributes:nil];
    }
    return temPath;
}
/**
 *
 *   获取缓存的文件夹的路径
 */
- (NSString *)getCache:(NSString *)downloadUrl withResponse:(NSURLResponse *)response customCahceName:(NSString *)customCacheName{
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DGDownload"];
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
    for (DGDownloadItem *item in _DG_DownloadArray) {
        if (item.downloadStatus == DGDownloadStatusDownloading) {
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
        for (DGDownloadItem *item in _DG_DownloadArray) {
            if (item.downloadStatus == DGDownloadStatusWaiting) {
                if (self.DG_MaxTaskCount == 0) {
                    self.DG_MaxTaskCount = MAXTASK_COUNT;
                }
                if (self.DG_MaxTaskCount - downloadingCount > 0) {
                    [self DG_BeginDownloadWithItem:item];
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

 @param item item
 */
- (void)DG_BeginDownloadWithItem:(DGDownloadItem *)item {
    
    if (item.requestUrl.length == 0) {
        return;
    }
    item.downloadStatus = DGDownloadStatusDownloading;
    //  如果任务正在进行 取消
    [self DG_CancelTask:item];
    //  取消请求的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //  开始下载任务
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:item.requestMethod URLString:item.requestUrl parameters:item.paramDic error:nil];
    // 读取数据
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:item.temPath error:nil];
    unsigned long long cacheNumber = dic.fileSize;
    // 断点续传
    if (cacheNumber > 0) {
        NSString *rangStr = [NSString stringWithFormat:@"bytes=%llu-",cacheNumber];
        [request setValue:rangStr forHTTPHeaderField:@"Range"];
    }
    __weak typeof(self)weakSelf = self;
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        [weakSelf.lock lock];
        
        item.downloadStatus = DGDownloadStatusDownloading;
        // 写入数据
        if (!item.itemFileHandle) {
            item.itemFileHandle = [NSFileHandle fileHandleForWritingAtPath:item.temPath];
        }
        [item.itemFileHandle seekToEndOfFile];
        [item.itemFileHandle writeData:data];
        // 计算进度
        unsigned long long receiveNumber = (unsigned long long )dataTask.countOfBytesReceived + cacheNumber;
        unsigned long long expectNumber = (unsigned long long)dataTask.countOfBytesExpectedToReceive + cacheNumber;
        CGFloat progress = (CGFloat)receiveNumber/expectNumber *1.0;
        item.progress = progress;
        if (item.DGDownloadProgressBlock) {
            item.DGDownloadProgressBlock(progress);
        }
        [weakSelf.lock unlock];
    }];
    // 完成
    item.task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [weakSelf.lock lock];
        item.error = error;
        if (error) {
            item.downloadStatus = DGDownloadStatusError;
            if (item.DGDownloadCompletionHandler) {
                item.DGDownloadCompletionHandler(error);
            }
        }else {
            item.downloadStatus = DGDownloadStatusDownloadFinish;
            // 这个路径要根据自己的实际情况处理
            item.cachePath = [weakSelf getCache:item.requestUrl withResponse:response customCahceName:item.customCacheName];
            // 删除文件，防止出现错误
            [[NSFileManager defaultManager] removeItemAtPath:item.cachePath error:nil];
            // 存放到自己想存放的路径
            NSError *transError = nil;
            [[NSFileManager defaultManager] moveItemAtPath:item.temPath toPath:item.cachePath error:&transError];
            
            [DGFileManager saveDownloaditem:item];
            // 从数组中移除成功的
            [weakSelf.DG_DownloadArray removeObject:item];
            // 删除临时的文件
            [[NSFileManager defaultManager] removeItemAtPath:item.temPath error:nil];
            if (item.DGDownloadCompletionHandler) {
                item.DGDownloadCompletionHandler(nil);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadFinish object:nil];
            item.response = response;
            // 递归调用
            [weakSelf DG_CheckDownload];
        }
        [weakSelf.lock unlock];
    }];
    
    [item.task resume];
    item.manager = manager;
}
/**
 *
 *  取消正在下载的任务
 */
- (void)DG_CancelTask:(DGDownloadItem *)item {
    
    if (item.task) {
        [item.task cancel];
        item.task = nil;
    }
    item.progress = 0;
    [item.manager setDataTaskDidReceiveDataBlock:NULL];
    item.response = nil;
    item.error = nil;
}
#pragma mark -- 内部监听方法调用

/// 监听网络变化自动恢复下载
- (void)listenNetwork{
    
    __weak typeof(DGDownloadManager *)weakSelf = self;
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
