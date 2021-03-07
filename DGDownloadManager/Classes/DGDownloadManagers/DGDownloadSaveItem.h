//
//  DGDownloadSaveItem.h
//  DGDownloadManager
//
//  Created by Brown on 3/7/21.
//

#import <Foundation/Foundation.h>
#import "DGDownloadItem.h"

@interface DGDownloadSaveItem : NSObject<NSCoding>

/** 下载的自定义的缓存文件名*/
@property (nonatomic, copy) NSString *customCacheName;

/** 请求的url */
@property (nonatomic, copy) NSString *requestUrl;

/** 下载的状态 */
@property (nonatomic, assign) DGDownloadStatus downloadStatus;

/** 下载的进度 */
@property (nonatomic, assign) CGFloat progress;

/** 临时存储的文件路径 */
@property (nonatomic, copy) NSString *temPath;

/** 缓存的文件的路径 */
@property (nonatomic, copy) NSString *cachePath;

/** 请求的方法 */
@property (nonatomic, copy) NSString *requestMethod;

/** 参数 */
@property (nonatomic, strong) NSDictionary *paramDic;




@end


