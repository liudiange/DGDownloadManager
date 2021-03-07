//
//  DGFileManager.h
//  DGDownloadManager
//
//  Created by apple on 2019/2/26.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGDownloadSaveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGFileManager : NSObject
/**
 *
 *   创建目录
 */
+ (BOOL)DG_CreatPath:(NSString *)path;
/**
 *
 *   判断路径是佛存在
 */
+ (BOOL)DG_FileIsExist:(NSString *)path;
/**
 *
 *   删除文件
 */
+ (BOOL)DG_DeleteFile:(NSString *)path;
/**
 *
 *   获取缓存的文件夹路径
 */
+ (NSString *)DG_GetCachePath;

/// 存储下载完成的数据item
/// @param item item
+ (void)saveDownloaditem:(DGDownloadItem *)item;


/// 获取所有已经下载过的model
+ (NSMutableArray<DGDownloadSaveItem *> *)getAllDownloadItems;


@end

NS_ASSUME_NONNULL_END
