//
//  DGFileManager.m
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "DGFileManager.h"

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
@end
