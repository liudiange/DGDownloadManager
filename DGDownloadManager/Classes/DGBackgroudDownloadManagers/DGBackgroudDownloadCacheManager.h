//
//  DGCacheManager.h
//  DGDownloadManager
//
//  Created by Brown on 3/3/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGBackgroudDownloadModel.h"
#import "DGBackgroudDownloadSaveModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface DGBackgroudDownloadCacheManager : NSObject

/// 存储resumeData
/// @param downloadUrl 下载的url
/// @param resumeData resumedata
+ (void)saveResumeDataWithUrl:(NSString *)downloadUrl
            resumeData:(NSData *)resumeData;

/// 通过一个下载的连接来获取存储的resumedata
/// @param downloadUrl 下载的url
+ (NSData *)getResumeData:(NSString *)downloadUrl;

/// 删除一个resumedata
/// @param downloadUrl 下载的url
+ (void)deleteResumeDataWithUrl:(NSString *)downloadUrl;

/// 存储下载完成的数据model
/// @param model model
+ (void)saveDownloadModel:(DGBackgroudDownloadModel *)model;


/// 获取所有已经下载过的model
+ (NSMutableArray<DGBackgroudDownloadSaveModel *> *)getAllDownloadModels;

@end

NS_ASSUME_NONNULL_END
