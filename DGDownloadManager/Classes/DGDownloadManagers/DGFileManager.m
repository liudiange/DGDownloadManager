//
//  DGFileManager.m
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "DGFileManager.h"
#import "NSDataAdditions.h"


#define cacheItemDataPath [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DGDownload"] stringByAppendingPathComponent:@"cacheDownloadItems.plist"]

@implementation DGFileManager
/**
 *
 *   创建目录
 */
+ (BOOL)DG_CreatPath:(NSString *)path{
    if (path.length > 0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        BOOL flag = [manager createFileAtPath:path contents:nil attributes:nil];
        return flag;
    }
    return NO;
}
/**
 *
 *   判断路径是佛存在
 */
+ (BOOL)DG_FileIsExist:(NSString *)path{
    if (path.length > 0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        return [manager fileExistsAtPath:path];
    }
    return NO;
}
/**
 *
 *   删除文件
 */
+ (BOOL)DG_DeleteFile:(NSString *)path{
    if (path.length > 0) {
        NSFileManager * manager = [NSFileManager defaultManager];
        return [manager removeItemAtPath:path error:nil];
    }
    return NO;
    
}
/**
 *
 *   获取缓存的文件夹路径
 */
+ (NSString *)DG_GetCachePath{
    
    return [[NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/DG_LocalMusic"];
}

/// 存储下载完成的数据item
/// @param item item
+ (void)saveDownloaditem:(DGDownloadItem *)item{
    if (item.requestUrl.length == 0) {
        return;
    }
    NSMutableDictionary *resumeMap = [NSMutableDictionary new];
    NSString *key = [[item.requestUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheItemDataPath]) {
        [[NSFileManager defaultManager] createFileAtPath:cacheItemDataPath contents:nil attributes:nil];
    }else{
       resumeMap = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:cacheItemDataPath];
    }
    
    DGDownloadSaveItem *saveItem = [[DGDownloadSaveItem alloc] init];
    saveItem.requestUrl = item.requestUrl;
    saveItem.customCacheName = item.customCacheName;
    saveItem.cachePath = item.cachePath;
    saveItem.progress = item.progress;
    saveItem.downloadStatus = item.downloadStatus;
    saveItem.temPath = item.temPath;
    saveItem.paramDic = item.paramDic;
    saveItem.requestMethod = item.requestMethod;
    resumeMap[key] = saveItem;
    [NSKeyedArchiver archiveRootObject:resumeMap toFile:cacheItemDataPath];
}


/// 获取所有已经下载过的model
+ (NSMutableArray<DGDownloadSaveItem *> *)getAllDownloadItems{
    
    NSMutableDictionary *resumeMap = [NSMutableDictionary new];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheItemDataPath]) {
        return nil;
    }else{
       resumeMap = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:cacheItemDataPath];
    }
    if (resumeMap.allKeys.count == 0) {
        return nil;
    }
    NSMutableArray *temArray = [NSMutableArray array];
    for (DGDownloadSaveItem *item in resumeMap.allValues) {
        [temArray addObject:item];
    }
    return temArray;
    
}

@end
