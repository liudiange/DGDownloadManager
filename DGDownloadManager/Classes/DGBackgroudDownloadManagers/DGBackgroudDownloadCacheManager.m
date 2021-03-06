//
//  DGCacheManager.m
//  DGDownloadManager
//
//  Created by Brown on 3/3/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import "DGBackgroudDownloadCacheManager.h"
#import "NSData+Category.h"
#import <objc/message.h>

#define cacheDataPath [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DGBackgroudDownload"] stringByAppendingPathComponent:@"cacheResumeData.plist"]

@implementation DGBackgroudDownloadCacheManager

/// 存储resumeData
/// @param downloadUrl 下载的url
/// @param resumeData resumedata
+ (void)saveResumeDataWithUrl:(NSString *)downloadUrl resumeData:(NSData *)resumeData{
    
    if (downloadUrl.length == 0 || resumeData.length == 0) {
        return;
    }
    NSMutableDictionary *resumeMap = [NSMutableDictionary new];
    NSString *key = [[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
        [[NSFileManager defaultManager] createFileAtPath:cacheDataPath contents:nil attributes:nil];
    }else{
       resumeMap = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:cacheDataPath];
    }
    resumeMap[key] = resumeData;
    [NSKeyedArchiver archiveRootObject:resumeMap toFile:cacheDataPath];
    
}

/// 通过一个下载的连接来获取存储的resumedata
/// @param downloadUrl 下载的url
+ (NSData *)getResumeData:(NSString *)downloadUrl{
    
    if (downloadUrl.length == 0) {
        return nil;
    }
    NSString *key = [[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString];
    NSData *resumeData;
    NSMutableDictionary *resumeMap = [NSMutableDictionary new];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
        return nil;
    }else{
       resumeMap = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:cacheDataPath];
    }
    if ([resumeMap.allKeys containsObject:key]) {
        resumeData = resumeMap[key];
    }
    return resumeData;
}

/// 删除一个resumedata
/// @param downloadUrl 下载的url
+ (void)deleteResumeDataWithUrl:(NSString *)downloadUrl{
    
    if (downloadUrl.length == 0) {
        return;
    }
    NSString *key = [[downloadUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString];
    NSMutableDictionary *resumeMap = [NSMutableDictionary new];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
        return ;
    }else{
       resumeMap = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:cacheDataPath];
    }
    if ([resumeMap.allKeys containsObject:key]) {
        [resumeMap removeObjectForKey:key];
        [NSKeyedArchiver archiveRootObject:resumeMap toFile:cacheDataPath];
    }
}

@end
